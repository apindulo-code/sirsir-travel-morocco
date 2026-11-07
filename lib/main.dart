import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SirSirApp());
}

const Color primaryRed = Color(0xFFC62828);
const Color darkNavy = Color(0xFF17243A);
const Color backgroundColor = Color(0xFFF5F6FA);

class SirSirApp extends StatelessWidget {
  const SirSirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SirSir Travel Morocco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// -------------------- DATA --------------------

class Trip {
  final String company;
  final String origin;
  final String destination;
  final String departure;
  final String arrival;
  final int price;
  final String type;

  const Trip({
    required this.company,
    required this.origin,
    required this.destination,
    required this.departure,
    required this.arrival,
    required this.price,
    required this.type,
  });
}

class Booking {
  final String reference;
  final Trip trip;
  final DateTime date;

  Booking({
    required this.reference,
    required this.trip,
    required this.date,
  });
}

const List<String> moroccanCities = [
  'طنجة',
  'تطوان',
  'المضيق',
  'مرتيل',
  'العرائش',
  'القنيطرة',
  'الرباط',
  'الدار البيضاء',
  'المحمدية',
  'الجديدة',
  'آسفي',
  'الصويرة',
  'أكادير',
  'مراكش',
  'بني ملال',
  'خريبكة',
  'فاس',
  'مكناس',
  'وجدة',
  'الناظور',
  'الحسيمة',
  'شفشاون',
  'ورزازات',
  'العيون',
  'الداخلة',
];

const List<Trip> sampleTrips = [
  Trip(
    company: 'CTM',
    origin: 'طنجة',
    destination: 'الدار البيضاء',
    departure: '08:30',
    arrival: '13:30',
    price: 140,
    type: 'حافلة عادية',
  ),
  Trip(
    company: 'Supratours',
    origin: 'طنجة',
    destination: 'الدار البيضاء',
    departure: '10:15',
    arrival: '15:15',
    price: 130,
    type: 'حافلة مريحة',
  ),
  Trip(
    company: 'CTM',
    origin: 'طنجة',
    destination: 'الدار البيضاء',
    departure: '14:00',
    arrival: '19:00',
    price: 170,
    type: 'VIP',
  ),
  Trip(
    company: 'CTM',
    origin: 'تطوان',
    destination: 'الرباط',
    departure: '09:00',
    arrival: '14:30',
    price: 120,
    type: 'حافلة عادية',
  ),
  Trip(
    company: 'Supratours',
    origin: 'مراكش',
    destination: 'أكادير',
    departure: '11:00',
    arrival: '14:00',
    price: 90,
    type: 'حافلة مريحة',
  ),
  Trip(
    company: 'CTM',
    origin: 'الرباط',
    destination: 'فاس',
    departure: '08:00',
    arrival: '11:00',
    price: 85,
    type: 'حافلة عادية',
  ),
];

// -------------------- HOME --------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String origin = 'طنجة';
  String destination = 'الدار البيضاء';
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سير سير 🇲🇦',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'SirSir Travel Morocco',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.confirmation_number_outlined),
            tooltip: 'حجوزاتي',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BookingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkNavy, Color(0xFF344C70)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اكتشف المغرب معنا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'رحلتك القادمة تبدأ من هنا',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'من الشمال إلى الجنوب',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'ابحث عن رحلتك',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 12),
            _citySelector(
              label: 'مدينة الانطلاق',
              value: origin,
              icon: Icons.trip_origin,
              onChanged: (value) {
                if (value != null) setState(() => origin = value);
              },
            ),
            const SizedBox(height: 10),
            _citySelector(
              label: 'مدينة الوصول',
              value: destination,
              icon: Icons.location_on,
              onChanged: (value) {
                if (value != null) setState(() => destination = value);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(
                'تاريخ السفر: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                icon: const Icon(Icons.search),
                label: const Text(
                  'ابحث عن الرحلات',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (origin == destination) {
                    _message('اختر مدينتين مختلفتين');
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(
                        origin: origin,
                        destination: destination,
                        travelDate: selectedDate,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'خدمات سير سير',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _serviceCard(
                    icon: Icons.confirmation_number,
                    title: 'حجوزاتي',
                    subtitle: 'تذاكرك',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _serviceCard(
                    icon: Icons.stadium,
                    title: 'رادار الملاعب',
                    subtitle: 'ملاعب المغرب',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StadiumScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _serviceCard(
              icon: Icons.explore,
              title: 'اكتشف المغرب',
              subtitle: 'أماكن سياحية وخرائط',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiscoverScreen(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user, color: primaryRed),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'الحجز الرسمي للتذاكر',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'انتقل إلى المنصات الرسمية للتحقق من المواعيد والأسعار وإتمام الدفع بأمان.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _openOfficialBooking(
                              'https://booking.ctm.ma/',
                            ),
                            icon: const Icon(Icons.directions_bus),
                            label: const Text('CTM'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openOfficialBooking(
                              'https://www.oncf-voyages.ma/',
                            ),
                            icon: const Icon(Icons.train),
                            label: const Text('ONCF'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'هذه نسخة تجريبية. مواعيد الرحلات والأسعار المعروضة ليست بيانات مباشرة أو عروض حجز مؤكدة.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _citySelector({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryRed),
          border: InputBorder.none,
        ),
        isExpanded: true,
        items: moroccanCities.map((city) {
          return DropdownMenuItem(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryRed, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOfficialBooking(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _message('تعذر فتح الموقع. تحقق من اتصال الإنترنت وحاول مجدداً.');
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// -------------------- DISCOVER MOROCCO --------------------

class TouristPlace {
  final String name;
  final String city;
  final String description;
  const TouristPlace({
    required this.name,
    required this.city,
    required this.description,
  });
}

const List<TouristPlace> touristPlaces = [
  TouristPlace(
    name: 'المدينة العتيقة',
    city: 'تطوان',
    description: 'أزقة تاريخية وأسواق تقليدية، وهي جزء من التراث العالمي لليونسكو.',
  ),
  TouristPlace(
    name: 'قصبة شفشاون',
    city: 'شفشاون',
    description: 'قصبة تاريخية وحديقة هادئة في قلب المدينة الزرقاء.',
  ),
  TouristPlace(
    name: 'رأس الماء',
    city: 'شفشاون',
    description: 'منطقة طبيعية معروفة بمياهها الجارية وإطلالاتها الجبلية.',
  ),
  TouristPlace(
    name: 'مغارة هرقل',
    city: 'طنجة',
    description: 'مغارة ساحلية شهيرة قرب رأس سبارطيل.',
  ),
  TouristPlace(
    name: 'رأس سبارطيل',
    city: 'طنجة',
    description: 'منطقة ساحلية تطل على المحيط الأطلسي ومضيق جبل طارق.',
  ),
  TouristPlace(
    name: 'ساحة جامع الفنا',
    city: 'مراكش',
    description: 'ساحة نابضة بالحياة قرب أسواق المدينة العتيقة.',
  ),
  TouristPlace(
    name: 'صومعة حسان',
    city: 'الرباط',
    description: 'معلمة تاريخية بارزة بجوار ضريح محمد الخامس.',
  ),
  TouristPlace(
    name: 'باب بوجلود',
    city: 'فاس',
    description: 'بوابة شهيرة تؤدي إلى أزقة فاس البالي التاريخية.',
  ),
  TouristPlace(
    name: 'قصبة أكادير أوفلا',
    city: 'أكادير',
    description: 'موقع مرتفع يوفر إطلالة واسعة على مدينة أكادير والخليج.',
  ),
  TouristPlace(
    name: 'مسجد الحسن الثاني',
    city: 'الدار البيضاء',
    description: 'معلمة معمارية بارزة على ساحل المحيط الأطلسي.',
  ),
];

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  Future<void> _openMap(BuildContext context, TouristPlace place) async {
    final query = Uri.encodeComponent('${place.name} ${place.city} المغرب');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الخرائط. تحقق من اتصال الإنترنت.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اكتشف المغرب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'وجهات مغربية تستحق الزيارة 🇲🇦\nاختر مكاناً وافتح موقعه على الخريطة.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...touristPlaces.map((place) => Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.place, color: primaryRed),
                  ),
                  title: Text(place.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${place.city} • ${place.description}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'افتح على الخريطة',
                    icon: const Icon(Icons.map_outlined, color: primaryRed),
                    onPressed: () => _openMap(context, place),
                  ),
                  onTap: () => _openMap(context, place),
                ),
              )),
          const SizedBox(height: 8),
          const Text(
            'هذه اقتراحات تعريفية للزيارة. تحقق من أوقات العمل وشروط الدخول قبل التنقل.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// -------------------- RESULTS --------------------

class ResultsScreen extends StatelessWidget {
  final String origin;
  final String destination;
  final DateTime travelDate;

  const ResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.travelDate,
  });

  @override
  Widget build(BuildContext context) {
    final trips = sampleTrips.where((trip) {
      return trip.origin == origin &&
          trip.destination == destination;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('الرحلات المتاحة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    origin,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward, color: primaryRed),
                Expanded(
                  child: Text(
                    destination,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تاريخ السفر: ${travelDate.day}/${travelDate.month}/${travelDate.year}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          if (trips.isEmpty)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Icon(Icons.directions_bus_outlined,
                      size: 55, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'لا توجد رحلات تجريبية لهذا المسار حالياً.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'هذا لا يعني عدم وجود رحلات حقيقية؛ التطبيق لم يتصل بعد بمصادر الشركات.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else ...[
            const Text(
              'نتائج تجريبية',
              style: TextStyle(
                color: primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...trips.map(
              (trip) => TripCard(
                trip: trip,
                onBook: () => _book(context, trip),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _book(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          trip: trip,
          travelDate: travelDate,
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onBook;

  const TripCard({
    super.key,
    required this.trip,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.directions_bus, color: primaryRed),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    trip.company,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${trip.price} DH',
                  style: const TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeColumn('الانطلاق', trip.departure),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _timeColumn('الوصول', trip.arrival),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(trip.type)),
                FilledButton(
                  onPressed: onBook,
                  child: const Text('متابعة الحجز'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn(String label, String time) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// -------------------- BOOKING --------------------

class BookingScreen extends StatefulWidget {
  final Trip trip;
  final DateTime travelDate;

  const BookingScreen({
    super.key,
    required this.trip,
    required this.travelDate,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات المسافر')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TripCard(
            trip: widget.trip,
            onBook: () {},
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم الكامل',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ملاحظة: هذا حجز تجريبي محلي، ولا يتم إرسال بياناتك إلى شركة نقل أو إصدار تذكرة سفر صالحة.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: confirmed ? null : _confirmBooking,
              child: const Text('إنشاء حجز تجريبي'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الاسم ورقم هاتف صحيح'),
        ),
      );
      return;
    }

    final reference =
        'SSR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final booking = Booking(
      reference: reference,
      trip: widget.trip,
      date: widget.travelDate,
    );

    setState(() => confirmed = true);
    BookingStore.add(booking);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TicketScreen(booking: booking),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

class BookingStore {
  static final List<Booking> bookings = [];

  static void add(Booking booking) {
    bookings.add(booking);
  }
}

// -------------------- TICKET --------------------

class TicketScreen extends StatelessWidget {
  final Booking booking;

  const TicketScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final trip = booking.trip;

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(
              Icons.confirmation_number,
              size: 65,
              color: primaryRed,
            ),
            const SizedBox(height: 12),
            const Text(
              'تم إنشاء الحجز التجريبي',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ticketLine('رقم الحجز', booking.reference),
                    _ticketLine('الشركة', trip.company),
                    _ticketLine('الانطلاق', trip.origin),
                    _ticketLine('الوصول', trip.destination),
                    _ticketLine('ساعة السفر', trip.departure),
                    _ticketLine(
                      'التاريخ',
                      '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                    ),
                    _ticketLine('السعر التجريبي', '${trip.price} DH'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'هذا ليس تذكرة نقل رسمية ولا يؤكد مقعداً لدى الشركة.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('العودة إلى الرئيسية'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- MY BOOKINGS --------------------

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = BookingStore.bookings.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: bookings.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.luggage, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('لا توجد حجوزات في هذه الجلسة'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(
                      Icons.confirmation_number,
                      color: primaryRed,
                    ),
                    title: Text(
                      '${booking.trip.origin} ← ${booking.trip.destination}',
                    ),
                    subtitle: Text(
                      'المرجع: ${booking.reference}\n'
                      '${booking.trip.company} - ${booking.trip.price} DH',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}

// -------------------- STADIUM RADAR --------------------

class Stadium {
  final String name;
  final String city;
  final String capacity;
  final String description;

  const Stadium({
    required this.name,
    required this.city,
    required this.capacity,
    required this.description,
  });
}

const List<Stadium> stadiums = [
  Stadium(
    name: 'ملعب ابن بطوطة',
    city: 'طنجة',
    capacity: 'حوالي 75,000',
    description: 'ملعب كبير بمدينة طنجة، يحتضن مباريات كرة القدم.',
  ),
  Stadium(
    name: 'مركب محمد الخامس',
    city: 'الدار البيضاء',
    capacity: 'حوالي 45,000',
    description: 'من أشهر الملاعب المغربية في مدينة الدار البيضاء.',
  ),
  Stadium(
    name: 'ملعب الأمير مولاي عبد الله',
    city: 'الرباط',
    capacity: 'حوالي 68,000',
    description: 'ملعب رياضي رئيسي بالعاصمة الرباط.',
  ),
  Stadium(
    name: 'الملعب الكبير لمراكش',
    city: 'مراكش',
    capacity: 'حوالي 45,000',
    description: 'ملعب رياضي بمدينة مراكش.',
  ),
  Stadium(
    name: 'ملعب أدرار',
    city: 'أكادير',
    capacity: 'حوالي 45,000',
    description: 'ملعب رياضي بمدينة أكادير.',
  ),
  Stadium(
    name: 'المركب الرياضي بفاس',
    city: 'فاس',
    capacity: 'حوالي 45,000',
    description: 'ملعب رياضي بمدينة فاس.',
  ),
];

class StadiumScreen extends StatelessWidget {
  const StadiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رادار ملاعب المغرب')),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.stadium, color: Colors.white, size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'اكتشف الملاعب المغربية\nوتعرّف على المدن الرياضية',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ...stadiums.map(
            (stadium) => Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.stadium, color: primaryRed),
                ),
                title: Text(
                  stadium.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${stadium.city} • السعة: ${stadium.capacity}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StadiumDetailsScreen(
                        stadium: stadium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'المعلومات تعريفية وتجريبية. لا توجد حالياً بيانات مباشرة عن المباريات أو حالة الملاعب.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class StadiumDetailsScreen extends StatelessWidget {
  final Stadium stadium;

  const StadiumDetailsScreen({
    super.key,
    required this.stadium,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معلومات الملعب')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.stadium,
                size: 90,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              stadium.name,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _detail(Icons.location_city, 'المدينة', stadium.city),
            _detail(Icons.people, 'السعة', stadium.capacity),
            _detail(Icons.info_outline, 'معلومات', stadium.description),
            const SizedBox(height: 20),
            const Text(
              'المباريات والتنبيهات المباشرة ستحتاج إلى ربط مصدر رسمي للمواعيد والنتائج.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$title: $value'),
          ),
        ],
      ),
    );
  }
}
