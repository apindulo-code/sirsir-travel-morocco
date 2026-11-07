import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TravelDashboard extends StatefulWidget {
  const TravelDashboard({super.key});
  @override
  State<TravelDashboard> createState() => _TravelDashboardState();
}

class _TravelDashboardState extends State<TravelDashboard> with SingleTickerProviderStateMixin {
  static const cities = <String, List<double>>{
    'طنجة':[35.7595,-5.8340], 'تطوان':[35.5889,-5.3626], 'المضيق':[35.6850,-5.3250],
    'مرتيل':[35.6167,-5.2750], 'الرباط':[34.0209,-6.8416], 'الدار البيضاء':[33.5731,-7.5898],
    'المحمدية':[33.6866,-7.3830], 'الجديدة':[33.2316,-8.5007], 'آسفي':[32.2994,-9.2372],
    'الصويرة':[31.5085,-9.7595], 'أكادير':[30.4278,-9.5981], 'مراكش':[31.6295,-7.9811],
    'فاس':[34.0331,-5.0003], 'مكناس':[33.8935,-5.5473], 'وجدة':[34.6814,-1.9086],
    'الناظور':[35.1681,-2.9335], 'الحسيمة':[35.2517,-3.9372], 'شفشاون':[35.1688,-5.2636],
    'العرائش':[35.1932,-6.1561], 'القنيطرة':[34.2610,-6.5802], 'بني ملال':[32.3373,-6.3498],
    'خريبكة':[32.8811,-6.9063], 'ورزازات':[30.9335,-6.9370], 'العيون':[27.1536,-13.2033],
    'الداخلة':[23.6848,-15.9570],
  };
  String city = 'الدار البيضاء';
  bool loading = true;
  String? error;
  Map<String,dynamic>? weather, sea, prayer;
  String location = 'المدينة المختارة';
  late final AnimationController ticker;

  @override
  void initState() {
    super.initState();
    ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
    // Restore the last selected city. The user can still request GPS manually.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreCity());
  }
  @override
  void dispose() { ticker.dispose(); super.dispose(); }

  Future<void> _gps() async {
    try {
      // If GPS is switched off, guide the user to Android location settings
      // instead of silently falling back to manual city selection.
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        final enableGps = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('خدمة الموقع متوقفة'),
            content: const Text('فعّل خدمة الموقع (GPS) في هاتفك، ثم اضغط «موقعي» مرة أخرى.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لاحقاً')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('فتح إعدادات الموقع')),
            ],
          ),
        );
        if (enableGps == true) await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إذن الموقع مطلوب'),
            content: const Text('سبق رفض إذن الموقع نهائياً. افتح إعدادات التطبيق واسمح بالوصول إلى الموقع أثناء استخدام التطبيق، ثم حاول مجدداً.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إعدادات التطبيق')),
            ],
          ),
        );
        if (openSettings == true) await Geolocator.openAppSettings();
        return;
      }

      if (permission == LocationPermission.denied) {
        _msg('لم يتم منح إذن الموقع. يمكنك المحاولة مجدداً أو اختيار المدينة يدوياً.');
        return;
      }

      if (!mounted) return;
      setState(() { loading = true; error = null; });
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final nearestCity = _nearestCity(position.latitude, position.longitude);
      city = nearestCity;
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString('travel_city', nearestCity);
      } catch (_) {}
      await _load(
        position.latitude,
        position.longitude,
        'موقعك الحالي • $nearestCity',
      );
    } catch (_) {
      if (mounted) {
        setState(() { loading = false; });
        _msg('تعذر تحديد الموقع. تأكد من تشغيل GPS ومنح الإذن، أو اختر المدينة يدوياً.');
      }
    }
  }

  String _nearestCity(double latitude, double longitude) {
    var nearest = city;
    var shortestDistance = double.infinity;
    for (final entry in cities.entries) {
      final point = entry.value;
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        point[0],
        point[1],
      );
      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  Future<void> _restoreCity() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString('travel_city');
      if (!mounted) return;
      await _loadCity(saved != null && cities.containsKey(saved) ? saved : city);
    } catch (_) {
      if (mounted) await _loadCity(city);
    }
  }

  Future<void> _loadCity(String name) async {
    city = name;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('travel_city', name);
    } catch (_) {}
    final p = cities[name]!;
    await _load(p[0], p[1], name);
  }
  Future<void> _load(double lat,double lon,String label) async {
    setState(() { loading=true; error=null; location=label; });
    try {
      final w=Uri.https('api.open-meteo.com','/v1/forecast',{
        'latitude':'$lat','longitude':'$lon',
        'current':'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m,pressure_msl',
        'daily':'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,pressure_msl_mean',
        'forecast_days':'5','timezone':'auto'});
      final p=Uri.https('api.aladhan.com','/v1/timings',{'latitude':'$lat','longitude':'$lon','method':'3'});
      final m=Uri.https('marine-api.open-meteo.com','/v1/marine',{
        'latitude':'$lat','longitude':'$lon','current':'wave_height,wave_period',
        'daily':'wave_height_max','forecast_days':'5','timezone':'auto'});
      final r=await Future.wait([http.get(w).timeout(const Duration(seconds:15)),http.get(p).timeout(const Duration(seconds:15)),http.get(m).timeout(const Duration(seconds:15))]);
      if(r[0].statusCode!=200 || r[1].statusCode!=200) throw Exception();
      final pw=jsonDecode(r[1].body) as Map<String,dynamic>;
      if((pw['code'] as num?)!=200) throw Exception();
      if(!mounted)return;
      setState(() { weather=jsonDecode(r[0].body) as Map<String,dynamic>; prayer=pw['data'] as Map<String,dynamic>; sea=r[2].statusCode==200?jsonDecode(r[2].body) as Map<String,dynamic>:null; loading=false; });
    } catch (_) { if(mounted)setState((){loading=false;error='تعذر جلب البيانات. تحقق من الإنترنت ثم حدّث الصفحة.';}); }
  }
  void _msg(String s){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  String _weatherName(dynamic v){final c=(v as num?)?.toInt()??-1;if(c==0)return'صحو';if(c<=3&&c>=1)return'غائم';if(c==45||c==48)return'ضباب';if(c>=51&&c<=67)return'رذاذ أو أمطار';if(c>=71&&c<=86)return'ثلوج';if(c>=95)return'عواصف رعدية';return'متغير';}
  String _advice(Map<String,dynamic> c){final w=(c['wind_speed_10m'] as num?)?.toDouble()??0;final rain=(c['precipitation'] as num?)?.toDouble()??0;final code=(c['weather_code'] as num?)?.toInt()??0;if(w>=55||code>=95)return'تنبيه: قد تؤثر الظروف الجوية على السفر. راجع النشرات الرسمية.';if(w>=35||rain>=2||[61,63,65,80,81,82].contains(code))return'الحذر مستحسن: تحقق من الطقس والطرق قبل الانطلاق.';return'المؤشرات الجوية تبدو ملائمة مبدئياً؛ تابع تحديثات الطريق.';}
  String _seaAdvice(dynamic value) {
    final height = (value as num?)?.toDouble();
    if (height == null) return 'لا تتوفر قراءة موثوقة للأمواج في هذه النقطة حالياً.';
    if (height >= 2.5) return 'الأمواج مرتفعة: تجنب الاقتراب من الصخور والحواجز، واتبع تعليمات السلطات المحلية.';
    if (height >= 1.5) return 'البحر مضطرب نسبياً: توخ الحذر قرب الشاطئ والصخور، ولا تعتمد على هذه القراءة وحدها.';
    if (height >= 0.8) return 'حالة الموج متوسطة تقريباً؛ تحقق من الرياح والمد والجزر والتنبيهات المحلية.';
    return 'ارتفاع الموج منخفض وفق القراءة الحالية، لكن ذلك لا يضمن سلامة السباحة أو الصيد.';
  }

  @override
  Widget build(BuildContext context){
    final c=weather?['current'] as Map<String,dynamic>?;
    final d=weather?['daily'] as Map<String,dynamic>?;
    final t=prayer?['timings'] as Map<String,dynamic>?;
    final mc=sea?['current'] as Map<String,dynamic>?;
    final md=sea?['daily'] as Map<String,dynamic>?;
    return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      Card(color:const Color(0xFF17243A),child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[
        Row(children:[const Icon(Icons.travel_explore,color:Colors.white),const SizedBox(width:8),const Expanded(child:Text('مركز معلومات السفر',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,fontSize:17))),IconButton(onPressed:loading?null:()=>_loadCity(city),icon:const Icon(Icons.refresh,color:Colors.white))]),
        Row(children:[Expanded(child:DropdownButton<String>(value:city,isExpanded:true,dropdownColor:Colors.white,underline:const SizedBox.shrink(),style:const TextStyle(color:Colors.white),items:cities.keys.map((n)=>DropdownMenuItem(value:n,child:Text(n,style:const TextStyle(color:Colors.black)))).toList(),onChanged:loading?null:(v){if(v!=null)_loadCity(v);})),OutlinedButton.icon(onPressed:loading?null:_gps,icon:const Icon(Icons.my_location),label:const Text('موقعي'),style:OutlinedButton.styleFrom(foregroundColor:Colors.white))]),
        Align(alignment:Alignment.centerRight,child:Text(location,style:const TextStyle(color:Colors.white70,fontSize:11))),
        const SizedBox(height:8),
        SizedBox(height:30,child:ClipRect(child:AnimatedBuilder(animation:ticker,builder:(context,_){return LayoutBuilder(builder:(context,b){return Stack(children:[Positioned(right:b.maxWidth-ticker.value*(b.maxWidth+750),top:5,child:const Text('تنبيهات السفر • تحقق من الطقس قبل الانطلاق • راجع مواعيد النقل من المصادر الرسمية • تابع تحذيرات البحر المحلية',maxLines:1,style:TextStyle(color:Colors.white,fontSize:12)))]);});}))),
      ]))),
      if(loading)const Padding(padding:EdgeInsets.all(20),child:Center(child:CircularProgressIndicator())),
      if(error!=null)Card(child:Padding(padding:const EdgeInsets.all(12),child:Text(error!))),
      if(c!=null&&!loading)...[
        Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('الطقس الآن',style:TextStyle(fontWeight:FontWeight.bold,fontSize:17)),
          Row(children:[const Icon(Icons.cloud,size:40,color:Colors.blue),Text(' ${(c['temperature_2m'] as num?)?.round()??'--'}°',style:const TextStyle(fontSize:30,fontWeight:FontWeight.bold)),const SizedBox(width:10),Text(_weatherName(c['weather_code']))]),
          Wrap(spacing:8,children:[Chip(label:Text('الرياح ${c['wind_speed_10m']} كم/س')),Chip(label:Text('الرطوبة ${c['relative_humidity_2m']}%')),Chip(label:Text('الأمطار ${c['precipitation']} مم')),Chip(label:Text('الضغط ${(c['pressure_msl'] as num?)?.round()??'--'} hPa'))]),
          Text(_advice(c),style:const TextStyle(fontWeight:FontWeight.w600)),
          const Text('مؤشر إرشادي وليس تحذيراً رسمياً أو ضماناً لسلامة الطريق.',style:TextStyle(color:Colors.grey,fontSize:11)),
        ]))),
        if(d!=null)Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('توقعات خمسة أيام',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
          ...List.generate((d['time'] as List).length,(i){final pl=d['pressure_msl_mean'] as List?;final p=pl!=null&&i<pl.length?(pl[i] as num?)?.toDouble():null;final trend=p==null?'':p<1005?' • ضغط منخفض محتمل':p>1020?' • ضغط مرتفع محتمل':' • ضغط معتدل';return ListTile(dense:true,contentPadding:EdgeInsets.zero,title:Text('${(d['time'] as List)[i]} • ${_weatherName((d['weather_code'] as List)[i])}'),subtitle:Text('${(d['temperature_2m_min'] as List)[i]}°–${(d['temperature_2m_max'] as List)[i]}° • أمطار ${(d['precipitation_probability_max'] as List)[i]}% • رياح ${(d['wind_speed_10m_max'] as List)[i]} كم/س$trend'));}),
        ]))),
        Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('حالة البحر',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
          if(mc?['wave_height']==null)const Text('بيانات الأمواج غير متاحة لهذه النقطة. اختر مدينة ساحلية.'),
          if(mc?['wave_height']!=null)...[Text('ارتفاع الموج: ${mc!['wave_height']} متر'),if(mc['wave_period']!=null)Text('فترة الموج: ${mc['wave_period']} ثانية'),if(md?['wave_height_max'] is List)Text('أقصى ارتفاع متوقع غداً: ${(md!['wave_height_max'] as List).length>1?(md['wave_height_max'] as List)[1]:'--'} متر')],
          if(mc?['wave_height']!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text(_seaAdvice(mc?['wave_height']),style:const TextStyle(fontWeight:FontWeight.w600))),
          const Text('ليست بديلاً عن تحذيرات الموانئ أو تعليمات السلامة والإنقاذ.',style:TextStyle(color:Colors.grey,fontSize:11)),
        ]))),
        Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('مواقيت الصلاة',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),
          if(t!=null)...['Fajr','Dhuhr','Asr','Maghrib','Isha'].map((k)=>ListTile(dense:true,contentPadding:EdgeInsets.zero,title:Text({'Fajr':'الفجر','Dhuhr':'الظهر','Asr':'العصر','Maghrib':'المغرب','Isha':'العشاء'}[k]!),trailing:Text((t[k]??'--').toString().split(' ').first,style:const TextStyle(fontWeight:FontWeight.bold)))),
          const Text('طريقة الحساب عامة؛ يُرجى مطابقتها مع التوقيت المحلي المعتمد.',style:TextStyle(color:Colors.grey,fontSize:11)),
        ]))),
      ],
      const Text('مصادر متابعة: الأرصاد المغربية • ONCF • CTM. البيانات تتحدث عند فتح الصفحة أو الضغط على تحديث.',style:TextStyle(color:Colors.grey,fontSize:11),textAlign:TextAlign.center),
    ]);
  }
}
