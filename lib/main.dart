import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'services/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'travel_dashboard.dart';

// Supported interface languages: Arabic, English, French and Spanish.
final ValueNotifier<String> appLanguage = ValueNotifier<String>('ar');
bool firebaseReady = false;

Future<void> changeAppLanguage(String language) async {
  appLanguage.value = language;
  final preferences = await SharedPreferences.getInstance();
  await preferences.setString('app_language', language);
}
const Map<String, List<String>> appTranslations = {
  'سير سير 🇲🇦': ['SirSir 🇲🇦', 'SirSir 🇲🇦', 'SirSir 🇲🇦'],
  'حجوزاتي': ['My bookings', 'Mes réservations', 'Mis reservas'],
  'خريطة المغرب': ['Map of Morocco', 'Carte du Maroc', 'Mapa de Marruecos'],
  'اللغة': ['Language', 'Langue', 'Idioma'],
  'اكتشف المغرب معنا': ['Discover Morocco with us', 'Découvrez le Maroc avec nous', 'Descubre Marruecos con nosotros'],
  'رحلتك القادمة تبدأ من هنا': ['Your next journey starts here', 'Votre prochain voyage commence ici', 'Tu próximo viaje comienza aquí'],
  'من الشمال إلى الجنوب': ['From north to south', 'Du nord au sud', 'De norte a sur'],
  'ابحث عن رحلتك': ['Find your trip', 'Recherchez votre trajet', 'Busca tu viaje'],
  'مدينة الانطلاق': ['Departure city', 'Ville de départ', 'Ciudad de salida'],
  'مدينة الوصول': ['Destination city', 'Ville d’arrivée', 'Ciudad de destino'],
  'ابحث عن الرحلات': ['Search trips', 'Rechercher des trajets', 'Buscar viajes'],
  'اختر مدينتين مختلفتين': ['Choose two different cities', 'Choisissez deux villes différentes', 'Elige dos ciudades diferentes'],
  'خدمات سير سير': ['SirSir services', 'Services SirSir', 'Servicios SirSir'],
  'تذاكرك': ['Your tickets', 'Vos billets', 'Tus billetes'],
  'رادار الملاعب': ['Stadium guide', 'Guide des stades', 'Guía de estadios'],
  'ملاعب المغرب': ['Moroccan stadiums', 'Stades du Maroc', 'Estadios de Marruecos'],
  'اكتشف المغرب': ['Discover Morocco', 'Découvrir le Maroc', 'Descubre Marruecos'],
  'أماكن سياحية وخرائط': ['Places and maps', 'Lieux touristiques et cartes', 'Lugares turísticos y mapas'],
  'الحجز الرسمي للتذاكر': ['Official ticket booking', 'Réservation officielle des billets', 'Reserva oficial de billetes'],
  'انتقل إلى المنصات الرسمية للتحقق من المواعيد والأسعار وإتمام الدفع بأمان.': ['Visit official platforms to check schedules and prices and pay securely.', 'Consultez les plateformes officielles pour vérifier les horaires et les prix et payer en toute sécurité.', 'Visita las plataformas oficiales para consultar horarios y precios y pagar de forma segura.'],
  'هذه نسخة تجريبية. مواعيد الرحلات والأسعار المعروضة ليست بيانات مباشرة أو عروض حجز مؤكدة.': ['This is a demo. Trip times and prices are not live data or confirmed booking offers.', 'Ceci est une version démo. Les horaires et les prix ne sont pas des données en direct ni des offres confirmées.', 'Esta es una versión de prueba. Los horarios y precios no son datos en directo ni ofertas confirmadas.'],
  'تعذر فتح الموقع. تحقق من اتصال الإنترنت وحاول مجدداً.': ['Could not open the website. Check your internet connection and try again.', 'Impossible d’ouvrir le site. Vérifiez votre connexion Internet et réessayez.', 'No se pudo abrir el sitio. Comprueba tu conexión a Internet e inténtalo de nuevo.'],
  'المدينة العتيقة': ['Old Medina', 'Ancienne médina', 'Medina antigua'],
  'قصبة شفشاون': ['Chefchaouen Kasbah', 'Kasbah de Chefchaouen', 'Kasbah de Chefchaouen'],
  'رأس الماء': ['Ras El Maa', 'Ras El Maa', 'Ras El Maa'],
  'مغارة هرقل': ['Hercules Cave', 'Grottes d’Hercule', 'Cuevas de Hércules'],
  'رأس سبارطيل': ['Cape Spartel', 'Cap Spartel', 'Cabo Espartel'],
  'ساحة جامع الفنا': ['Jemaa el-Fnaa Square', 'Place Jemaa el-Fna', 'Plaza Jemaa el-Fna'],
  'صومعة حسان': ['Hassan Tower', 'Tour Hassan', 'Torre Hassan'],
  'باب بوجلود': ['Bab Boujloud', 'Bab Boujloud', 'Bab Boujloud'],
  'قصبة أكادير أوفلا': ['Agadir Oufella Kasbah', 'Kasbah d’Agadir Oufella', 'Kasbah de Agadir Oufella'],
  'مسجد الحسن الثاني': ['Hassan II Mosque', 'Mosquée Hassan II', 'Mezquita Hassan II'],
  'لا توجد رحلات تجريبية لهذا المسار حالياً.': ['No demo trips are currently listed for this route.', 'Aucun trajet démo n’est actuellement proposé pour cet itinéraire.', 'No hay viajes de prueba disponibles para esta ruta.'],
  'نتائج تجريبية': ['Demo results', 'Résultats de démonstration', 'Resultados de prueba'],
  'بيانات المسافر': ['Passenger details', 'Informations du voyageur', 'Datos del pasajero'],
  'الاسم الكامل': ['Full name', 'Nom complet', 'Nombre completo'],
  'رقم الهاتف': ['Phone number', 'Numéro de téléphone', 'Número de teléfono'],
  'إنشاء حجز تجريبي': ['Create demo booking', 'Créer une réservation démo', 'Crear reserva de prueba'],
  'تفاصيل الحجز': ['Booking details', 'Détails de la réservation', 'Detalles de la reserva'],
  'تم إنشاء الحجز التجريبي': ['Demo booking created', 'Réservation démo créée', 'Reserva de prueba creada'],
  'العودة إلى الرئيسية': ['Back to home', 'Retour à l’accueil', 'Volver al inicio'],
  'لا توجد حجوزات في هذه الجلسة': ['No bookings in this session', 'Aucune réservation dans cette session', 'No hay reservas en esta sesión'],
  'معلومات الملعب': ['Stadium information', 'Informations sur le stade', 'Información del estadio'],
  'المدينة': ['City', 'Ville', 'Ciudad'],
  'السعة': ['Capacity', 'Capacité', 'Capacidad'],
  'معلومات': ['Information', 'Informations', 'Información'],

  'الرحلات المتاحة': ['Available trips', 'Trajets disponibles', 'Viajes disponibles'],
  'تاريخ السفر: ': ['Travel date: ', 'Date du voyage : ', 'Fecha del viaje: '],
  'هذا لا يعني عدم وجود رحلات حقيقية؛ التطبيق لم يتصل بعد بمصادر الشركات.': ['This does not mean real trips are unavailable; the app is not yet connected to transport providers.', 'Cela ne signifie pas qu’il n’existe aucun trajet réel ; l’application n’est pas encore connectée aux transporteurs.', 'Esto no significa que no haya viajes reales; la aplicación aún no está conectada a los proveedores.'],
  'الانطلاق': ['Departure', 'Départ', 'Salida'],
  'الوصول': ['Arrival', 'Arrivée', 'Llegada'],
  'متابعة الحجز': ['Continue booking', 'Continuer la réservation', 'Continuar reserva'],
  'ملاحظة: هذا حجز تجريبي محلي، ولا يتم إرسال بياناتك إلى شركة نقل أو إصدار تذكرة سفر صالحة.': ['Note: This is a local demo booking. Your details are not sent to a transport company and no valid travel ticket is issued.', 'Remarque : il s’agit d’une réservation démo locale. Vos données ne sont pas envoyées à un transporteur et aucun billet valide n’est émis.', 'Nota: Esta es una reserva de prueba local. Tus datos no se envían a ninguna empresa de transporte ni se emite un billete válido.'],
  'يرجى إدخال الاسم ورقم هاتف صحيح': ['Please enter your name and a valid phone number', 'Veuillez saisir votre nom et un numéro de téléphone valide', 'Introduce tu nombre y un número de teléfono válido'],
  'رقم الحجز': ['Booking reference', 'Référence de réservation', 'Referencia de reserva'],
  'الشركة': ['Operator', 'Compagnie', 'Compañía'],
  'ساعة السفر': ['Departure time', 'Heure de départ', 'Hora de salida'],
  'التاريخ': ['Date', 'Date', 'Fecha'],
  'السعر التجريبي': ['Demo price', 'Prix indicatif', 'Precio de prueba'],
  'هذا ليس تذكرة نقل رسمية ولا يؤكد مقعداً لدى الشركة.': ['This is not an official transport ticket and does not confirm a seat with the operator.', 'Ceci n’est pas un billet officiel et ne confirme aucune place auprès du transporteur.', 'Esto no es un billete oficial ni confirma un asiento con la compañía.'],
  'المرجع: ': ['Reference: ', 'Référence : ', 'Referencia: '],
  'ملعب ابن بطوطة': ['Ibn Batouta Stadium', 'Stade Ibn Batouta', 'Estadio Ibn Batouta'],
  'مركب محمد الخامس': ['Mohammed V Stadium', 'Complexe Mohammed V', 'Estadio Mohammed V'],
  'ملعب الأمير مولاي عبد الله': ['Prince Moulay Abdellah Stadium', 'Stade du Prince Moulay Abdellah', 'Estadio Príncipe Moulay Abdellah'],
  'الملعب الكبير لمراكش': ['Marrakech Grand Stadium', 'Grand Stade de Marrakech', 'Gran Estadio de Marrakech'],
  'ملعب أدرار': ['Adrar Stadium', 'Stade Adrar', 'Estadio Adrar'],
  'المركب الرياضي بفاس': ['Fez Sports Complex', 'Complexe sportif de Fès', 'Complejo deportivo de Fez'],
  'رادار ملاعب المغرب': ['Morocco Stadium Guide', 'Guide des stades du Maroc', 'Guía de estadios de Marruecos'],
  'اكتشف الملاعب المغربية\nوتعرّف على المدن الرياضية': ['Discover Moroccan stadiums\nand sports cities', 'Découvrez les stades marocains\net les villes sportives', 'Descubre los estadios marroquíes\ny las ciudades deportivas'],
  'السعة: ': ['Capacity: ', 'Capacité : ', 'Capacidad: '],
  'المعلومات تعريفية وتجريبية. لا توجد حالياً بيانات مباشرة عن المباريات أو حالة الملاعب.': ['This is general demo information. Live match or stadium-status data is not currently available.', 'Ces informations sont générales et données à titre de démonstration. Aucune donnée en direct sur les matchs ou l’état des stades n’est disponible.', 'Esta información es orientativa y de demostración. Actualmente no hay datos en directo sobre partidos o el estado de los estadios.'],
  'المباريات والتنبيهات المباشرة ستحتاج إلى ربط مصدر رسمي للمواعيد والنتائج.': ['Live matches and alerts will require an official schedule and results data source.', 'Les matchs et alertes en direct nécessiteront une source officielle pour les calendriers et les résultats.', 'Los partidos y avisos en directo requerirán una fuente oficial de horarios y resultados.'],
  'تعذر فتح الخرائط. تحقق من اتصال الإنترنت.': ['Could not open maps. Check your internet connection.', 'Impossible d’ouvrir les cartes. Vérifiez votre connexion Internet.', 'No se pudieron abrir los mapas. Comprueba tu conexión a Internet.'],
  'وجهات مغربية تستحق الزيارة 🇲🇦\nاختر مكاناً وافتح موقعه على الخريطة.': ['Moroccan destinations worth visiting 🇲🇦\nChoose a place to view it on the map.', 'Des destinations marocaines à découvrir 🇲🇦\nChoisissez un lieu pour l’afficher sur la carte.', 'Destinos marroquíes que merecen una visita 🇲🇦\nElige un lugar para verlo en el mapa.'],
  'افتح على الخريطة': ['Open map', 'Ouvrir la carte', 'Abrir mapa'],
  'هذه اقتراحات تعريفية للزيارة. تحقق من أوقات العمل وشروط الدخول قبل التنقل.': ['These are suggested places to visit. Check opening hours and entry requirements before travelling.', 'Ces lieux sont proposés à titre indicatif. Vérifiez les horaires et les conditions d’accès avant de vous déplacer.', 'Estos son lugares sugeridos para visitar. Comprueba los horarios y las condiciones de acceso antes de desplazarte.'],
};
String tr(String source) {
  final values = appTranslations[source];
  if (values == null) return source;
  final index = {'en': 0, 'fr': 1, 'es': 2}[appLanguage.value] ?? -1;
  return index < 0 ? source : values[index];
}
String cityLabel(String city) {
  const names = {
    'طنجة': ['Tangier', 'Tanger', 'Tánger'], 'تطوان': ['Tetouan', 'Tétouan', 'Tetuán'],
    'المضيق': ['Mdiq', 'M’diq', 'Mdiq'], 'مرتيل': ['Martil', 'Martil', 'Martil'],
    'العرائش': ['Larache', 'Larache', 'Larache'], 'القنيطرة': ['Kenitra', 'Kénitra', 'Kenitra'],
    'الرباط': ['Rabat', 'Rabat', 'Rabat'], 'الدار البيضاء': ['Casablanca', 'Casablanca', 'Casablanca'],
    'المحمدية': ['Mohammedia', 'Mohammedia', 'Mohammedia'], 'الجديدة': ['El Jadida', 'El Jadida', 'El Jadida'],
    'آسفي': ['Safi', 'Safi', 'Safi'], 'الصويرة': ['Essaouira', 'Essaouira', 'Essaouira'],
    'أكادير': ['Agadir', 'Agadir', 'Agadir'], 'مراكش': ['Marrakech', 'Marrakech', 'Marrakech'],
    'بني ملال': ['Beni Mellal', 'Béni Mellal', 'Beni Mellal'], 'خريبكة': ['Khouribga', 'Khouribga', 'Khouribga'],
    'فاس': ['Fez', 'Fès', 'Fez'], 'مكناس': ['Meknes', 'Meknès', 'Mequinez'],
    'وجدة': ['Oujda', 'Oujda', 'Uchda'], 'الناظور': ['Nador', 'Nador', 'Nador'],
    'الحسيمة': ['Al Hoceima', 'Al Hoceïma', 'Alhucemas'], 'شفشاون': ['Chefchaouen', 'Chefchaouen', 'Chauen'],
    'ورزازات': ['Ouarzazate', 'Ouarzazate', 'Ouarzazate'], 'العيون': ['Laayoune', 'Laâyoune', 'El Aaiún'],
    'الداخلة': ['Dakhla', 'Dakhla', 'Dajla']
  };
  final values = names[city];
  final index = {'en': 0, 'fr': 1, 'es': 2}[appLanguage.value] ?? -1;
  return values == null || index < 0 ? city : values[index];
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final savedLanguage = preferences.getString('app_language');
  if (savedLanguage != null && ['ar', 'en', 'fr', 'es'].contains(savedLanguage)) {
    appLanguage.value = savedLanguage;
  }
  // Firebase is initialized when valid project options are available, but a
  // backend outage must never prevent the public travel dashboard from opening.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase initialization unavailable: $error');
    firebaseReady = false;
  }
  runApp(const SirSirApp());
}

const Color primaryRed = Color(0xFFC62828);
const Color darkNavy = Color(0xFF17243A);
const Color backgroundColor = Color(0xFFF5F6FA);

class SirSirApp extends StatelessWidget {
  const SirSirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguage,
      builder: (context, language, _) => MaterialApp(
      locale: Locale(language),
      builder: (context, child) => Directionality(
        textDirection: language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
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
    ));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('سير سير 🇲🇦'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'SirSir Travel Morocco',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: tr('اللغة'),
            onSelected: (value) => changeAppLanguage(value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    {'ar': 'العربية', 'en': 'EN', 'fr': 'FR', 'es': 'ES'}[appLanguage.value] ?? 'العربية',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ar', child: Text('العربية')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'fr', child: Text('Français')),
              PopupMenuItem(value: 'es', child: Text('Español')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.confirmation_number_outlined),
            tooltip: tr('حجوزاتي'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BookingsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(firebaseReady ? Icons.account_circle_outlined : Icons.cloud_off_outlined),
            tooltip: 'حساب SirSir',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => firebaseReady
                    ? const AuthScreen()
                    : const FirebaseUnavailableScreen(),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('اكتشف المغرب معنا'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tr('رحلتك القادمة تبدأ من هنا'),
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
                        tr('من الشمال إلى الجنوب'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const TravelDashboard(),
            SizedBox(height: 22),
            Text(
              tr('ابحث عن رحلتك'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            SizedBox(height: 12),
            _citySelector(
              label: tr('مدينة الانطلاق'),
              value: origin,
              icon: Icons.trip_origin,
              onChanged: (value) {
                if (value != null) setState(() => origin = value);
              },
            ),
            SizedBox(height: 10),
            _citySelector(
              label: tr('مدينة الوصول'),
              value: destination,
              icon: Icons.location_on,
              onChanged: (value) {
                if (value != null) setState(() => destination = value);
              },
            ),
            SizedBox(height: 12),
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
              icon: Icon(Icons.calendar_month),
              label: Text(
                'تاريخ السفر: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                icon: Icon(Icons.search),
                label: Text(
                  tr('ابحث عن الرحلات'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  if (origin == destination) {
                    _message(tr('اختر مدينتين مختلفتين'));
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
            SizedBox(height: 24),
            Text(
              tr('خدمات سير سير'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _serviceCard(
                    icon: Icons.confirmation_number,
                    title: tr('حجوزاتي'),
                    subtitle: tr('تذاكرك'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingsScreen(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _serviceCard(
                    icon: Icons.stadium,
                    title: tr('رادار الملاعب'),
                    subtitle: tr('ملاعب المغرب'),
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
            SizedBox(height: 12),
            _serviceCard(
              icon: Icons.explore,
              title: tr('اكتشف المغرب'),
              subtitle: tr('أماكن سياحية وخرائط'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiscoverScreen(),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.map_outlined),
                label: Text(tr('خريطة المغرب')),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _openMoroccoMap,
              ),
            ),
            SizedBox(height: 18),
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
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: primaryRed),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tr('الحجز الرسمي للتذاكر'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      tr('انتقل إلى المنصات الرسمية للتحقق من المواعيد والأسعار وإتمام الدفع بأمان.'),
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _openOfficialBooking(
                              'https://booking.ctm.ma/',
                            ),
                            icon: Icon(Icons.directions_bus),
                            label: Text('CTM'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openOfficialBooking(
                              'https://www.oncf-voyages.ma/',
                            ),
                            icon: Icon(Icons.train),
                            label: Text('ONCF'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr('هذه نسخة تجريبية. مواعيد الرحلات والأسعار المعروضة ليست بيانات مباشرة أو عروض حجز مؤكدة.'),
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
            child: Text(cityLabel(city)),
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
            SizedBox(height: 8),
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

  void _openMoroccoMap() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MoroccoMapScreen()));
  }

  Future<void> _openOfficialBooking(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _message(tr('تعذر فتح الموقع. تحقق من اتصال الإنترنت وحاول مجدداً.'));
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
  final double latitude;
  final double longitude;
  const TouristPlace({
    required this.name,
    required this.city,
    required this.description,
    required this.latitude,
    required this.longitude,
  });
}

const List<TouristPlace> touristPlaces = [
  TouristPlace(
    name: 'المدينة العتيقة',
    city: 'تطوان',
    description: 'أزقة تاريخية وأسواق تقليدية، وهي جزء من التراث العالمي لليونسكو.',
    latitude: 35.5711, longitude: -5.3724,
  ),
  TouristPlace(
    name: 'قصبة شفشاون',
    city: 'شفشاون',
    description: 'قصبة تاريخية وحديقة هادئة في قلب المدينة الزرقاء.',
    latitude: 35.1688, longitude: -5.2636,
  ),
  TouristPlace(
    name: 'رأس الماء',
    city: 'شفشاون',
    description: 'منطقة طبيعية معروفة بمياهها الجارية وإطلالاتها الجبلية.',
    latitude: 35.1752, longitude: -5.2608,
  ),
  TouristPlace(
    name: 'مغارة هرقل',
    city: 'طنجة',
    description: 'مغارة ساحلية شهيرة قرب رأس سبارطيل.',
    latitude: 35.7595, longitude: -5.9372,
  ),
  TouristPlace(
    name: 'رأس سبارطيل',
    city: 'طنجة',
    description: 'منطقة ساحلية تطل على المحيط الأطلسي ومضيق جبل طارق.',
    latitude: 35.7917, longitude: -5.9230,
  ),
  TouristPlace(
    name: 'ساحة جامع الفنا',
    city: 'مراكش',
    description: 'ساحة نابضة بالحياة قرب أسواق المدينة العتيقة.',
    latitude: 31.6258, longitude: -7.9891,
  ),
  TouristPlace(
    name: 'صومعة حسان',
    city: 'الرباط',
    description: 'معلمة تاريخية بارزة بجوار ضريح محمد الخامس.',
    latitude: 34.0242, longitude: -6.8229 
  ),
  TouristPlace(
    name: 'باب بوجلود',
    city: 'فاس',
    description: 'بوابة شهيرة تؤدي إلى أزقة فاس البالي التاريخية.',
    latitude: 34.0616, longitude: -4.9857,
  ),
  TouristPlace(
    name: 'قصبة أكادير أوفلا',
    city: 'أكادير',
    description: 'موقع مرتفع يوفر إطلالة واسعة على مدينة أكادير والخليج.',
    latitude: 30.4278, longitude: -9.6240,
  ),
  TouristPlace(
    name: 'مسجد الحسن الثاني',
    city: 'الدار البيضاء',
    description: 'معلمة معمارية بارزة على ساحل المحيط الأطلسي.',
    latitude: 33.6084, longitude: -7.6326,
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
        SnackBar(content: Text('تعذر فتح الخرائط. تحقق من اتصال الإنترنت.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('اكتشف المغرب'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'وجهات مغربية تستحق الزيارة 🇲🇦\nاختر مكاناً وافتح موقعه على الخريطة.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                height: 1.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 14),
          ...touristPlaces.map((place) => Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.place, color: primaryRed),
                  ),
                  title: Text(place.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${place.city} • ${place.description}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'افتح على الخريطة',
                    icon: Icon(Icons.map_outlined, color: primaryRed),
                    onPressed: () => _openMap(context, place),
                  ),
                  onTap: () => _openMap(context, place),
                ),
              )),
          SizedBox(height: 8),
          Text(
            'هذه اقتراحات تعريفية للزيارة. تحقق من أوقات العمل وشروط الدخول قبل التنقل.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// -------------------- INTERACTIVE MOROCCO MAP --------------------

class MoroccoMapScreen extends StatelessWidget {
  const MoroccoMapScreen({super.key});

  Future<void> _openPlace(TouristPlace place) async {
    final query = Uri.encodeComponent('${place.name} ${place.city} Morocco');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('خريطة المغرب'))),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(31.8, -6.2),
                initialZoom: 5.2,
                minZoom: 4.5,
                maxZoom: 17,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sirsir.travel.morocco',
                ),
                MarkerLayer(
                  markers: touristPlaces.map((place) => Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 46,
                    height: 54,
                    child: GestureDetector(
                      onTap: () => _openPlace(place),
                      child: const Icon(Icons.location_on, color: primaryRed, size: 42),
                    ),
                  )).toList(),
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: Colors.white,
            child: Text(
              tr('اضغط على علامة المكان لفتحه في خرائط Google.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
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
      appBar: AppBar(title: Text(tr('الرحلات المتاحة'))),
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
                    cityLabel(origin),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward, color: primaryRed),
                Expanded(
                  child: Text(
                    cityLabel(destination),
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
          SizedBox(height: 8),
          Text(
            'تاريخ السفر: ${travelDate.day}/${travelDate.month}/${travelDate.year}',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18),
          if (trips.isEmpty)
            Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Icon(Icons.directions_bus_outlined,
                      size: 55, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    tr('لا توجد رحلات تجريبية لهذا المسار حالياً.'),
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
            Text(
              tr('نتائج تجريبية'),
              style: TextStyle(
                color: primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
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
                CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.directions_bus, color: primaryRed),
                ),
                SizedBox(width: 10),
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
                _timeColumn(tr('الانطلاق'), trip.departure),
                Icon(Icons.arrow_forward, color: Colors.grey),
                _timeColumn(tr('الوصول'), trip.arrival),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(trip.type)),
                FilledButton(
                  onPressed: onBook,
                  child: Text(tr('متابعة الحجز')),
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
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('بيانات المسافر'))),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TripCard(
            trip: widget.trip,
            onBook: () {},
          ),
          SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: tr('الاسم الكامل'),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: tr('رقم الهاتف'),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'ملاحظة: هذا حجز تجريبي محلي، ولا يتم إرسال بياناتك إلى شركة نقل أو إصدار تذكرة سفر صالحة.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: confirmed || saving ? null : _confirmBooking,
              child: Text(saving ? 'جارٍ الحفظ…' : (firebaseReady && FirebaseAuth.instance.currentUser != null ? 'إرسال طلب الحجز' : tr('إنشاء حجز تجريبي'))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('يرجى إدخال الاسم ورقم هاتف صحيح'))),
      );
      return;
    }

    setState(() => saving = true);
    try {
      var reference = 'SSR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final signedIn = firebaseReady && FirebaseAuth.instance.currentUser != null;

      if (signedIn) {
        // This stores a request in the user's Firestore account. It is not a
        // confirmed seat or a ticket issued by the transport operator.
        reference = await FirestoreService().createBooking(
          origin: widget.trip.origin,
          destination: widget.trip.destination,
          travelDate: widget.travelDate,
          passengerName: name,
          passengerPhone: phone,
          providerName: widget.trip.company,
          displayedPrice: widget.trip.price,
        );
      }

      final booking = Booking(
        reference: reference,
        trip: widget.trip,
        date: widget.travelDate,
      );
      BookingStore.add(booking);
      if (!mounted) return;
      setState(() { confirmed = true; saving = false; });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TicketScreen(booking: booking)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر حفظ طلب الحجز في حسابك. تحقق من اتصال الإنترنت وقواعد Firestore ثم حاول مجدداً.'),
        ),
      );
    }
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
      appBar: AppBar(title: Text(tr('تفاصيل الحجز'))),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.confirmation_number,
              size: 65,
              color: primaryRed,
            ),
            SizedBox(height: 12),
            Text(
              tr('تم إنشاء الحجز التجريبي'),
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ticketLine(tr('رقم الحجز'), booking.reference),
                    _ticketLine(tr('الشركة'), trip.company),
                    _ticketLine(tr('الانطلاق'), cityLabel(trip.origin)),
                    _ticketLine(tr('الوصول'), cityLabel(trip.destination)),
                    _ticketLine(tr('ساعة السفر'), trip.departure),
                    _ticketLine(
                      tr('التاريخ'),
                      '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                    ),
                    _ticketLine(tr('السعر التجريبي'), '${trip.price} DH'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
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
                child: Text(tr('العودة إلى الرئيسية')),
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
    final signedIn = firebaseReady && FirebaseAuth.instance.currentUser != null;
    return Scaffold(
      appBar: AppBar(title: Text(tr('حجوزاتي'))),
      body: signedIn
          ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService().watchMyBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'تعذر تحميل حجوزاتك السحابية. تحقق من نشر قواعد Firestore واتصال الإنترنت.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return _emptyBookings();
                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final date = data['travelDate'] is Timestamp
                        ? (data['travelDate'] as Timestamp).toDate()
                        : null;
                    final status = data['status']?.toString() ?? 'requested';
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: const Icon(Icons.confirmation_number, color: primaryRed),
                        title: Text('${data['origin'] ?? ''} ← ${data['destination'] ?? ''}'),
                        subtitle: Text(
                          'المرجع: ${doc.id}\n${data['providerName'] ?? ''} • ${date == null ? 'تاريخ غير محدد' : '${date.day}/${date.month}/${date.year}'}\nالحالة: ${status == 'cancelled' ? 'ملغى' : 'طلب قيد المعالجة'}',
                        ),
                        isThreeLine: true,
                        trailing: status == 'cancelled'
                            ? const Icon(Icons.cancel_outlined, color: Colors.grey)
                            : IconButton(
                                tooltip: 'إلغاء طلب الحجز',
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await FirestoreService().cancelMyBooking(doc.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تم إلغاء طلب الحجز.')),
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('تعذر إلغاء الطلب. حاول لاحقاً.')),
                                      );
                                    }
                                  }
                                },
                              ),
                      ),
                    );
                  },
                );
              },
            )
          : _guestBookings(),
    );
  }

  Widget _emptyBookings() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.luggage, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(tr('لا توجد حجوزات في هذه الجلسة')),
        ],
      ),
    );
  }

  Widget _guestBookings() {
    final bookings = BookingStore.bookings.reversed.toList();
    if (bookings.isEmpty) return _emptyBookings();
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.confirmation_number, color: primaryRed),
            title: Text('${booking.trip.origin} ← ${booking.trip.destination}'),
            subtitle: Text(
              '${tr('المرجع: ')}${booking.reference}\n${booking.trip.company} - ${booking.trip.price} DH',
            ),
            isThreeLine: true,
          ),
        );
      },
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
      appBar: AppBar(title: Text(tr('رادار ملاعب المغرب'))),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
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
          SizedBox(height: 15),
          ...stadiums.map(
            (stadium) => Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.stadium, color: primaryRed),
                ),
                title: Text(
                  tr(stadium.name),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${cityLabel(stadium.city)} • ${tr('السعة: ')}${stadium.capacity}',
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 15),
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
          SizedBox(height: 8),
          Text(
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
      appBar: AppBar(title: Text(tr('معلومات الملعب'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.stadium,
                size: 90,
                color: primaryRed,
              ),
            ),
            SizedBox(height: 20),
            Text(
              stadium.name,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _detail(Icons.location_city, tr('المدينة'), stadium.city),
            _detail(Icons.people, tr('السعة'), stadium.capacity),
            _detail(Icons.info_outline, tr('معلومات'), tr(stadium.description)),
            SizedBox(height: 20),
            Text(
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
          SizedBox(width: 12),
          Expanded(
            child: Text('$title: $value'),
          ),
        ],
      ),
    );
  }
}


class FirebaseUnavailableScreen extends StatelessWidget {
  const FirebaseUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب SirSir')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'خدمة الحسابات غير متاحة حالياً. يمكنك استخدام معلومات السفر والخرائط كضيف. يرجى التحقق من إعدادات Firebase واتصال الإنترنت.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.6),
          ),
        ),
      ),
    );
  }
}
