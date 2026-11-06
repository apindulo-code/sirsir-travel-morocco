import 'package:flutter/material.dart';

void main() {
  runApp(const SirSirApp());
}

class SirSirApp extends StatelessWidget {
  const SirSirApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SirSir Travel Morocco',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _originCtrl = TextEditingController(text: 'طنجة');
  final TextEditingController _destCtrl = TextEditingController(text: 'الدار البيضاء');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1000&auto=format&fit=crop'), 
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('SirSir Travel 🇲🇦 سير سير'),
              backgroundColor: const Color(0xFFC62828),
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.sports_soccer, color: Colors.amber),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StadiumAlertsScreen()),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Icon(Icons.directions_bus_rounded, size: 50, color: Colors.white),
                    const SizedBox(height: 5),
                    const Text(
                      'طريقك للمدينة والملعب.. سير سير!',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _originCtrl,
                            decoration: const InputDecoration(
                              labelText: 'مدينة الانطلاق',
                              prefixIcon: Icon(Icons.my_location, color: Color(0xFFC62828)),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _destCtrl,
                            decoration: const InputDecoration(
                              labelText: 'وجهة الوصول',
                              prefixIcon: Icon(Icons.pin_drop, color: Color(0xFFC62828)),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultsScreen(
                                      origin: _originCtrl.text,
                                      dest: _destCtrl.text,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                '🔍 ابحث عن رحلات سير سير',
                                style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StadiumAlertsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber, width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.sports_soccer, color: Colors.amber, size: 28),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'رادار رحلات الملاعب والمباريات 🏆',
                                    style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'اضغط لمعرفة جدول رحلات حافلات الملاعب الكبرى',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripData {
  final String company;
  final String time;
  final String price;
  final String description;

  const TripData(this.company, this.time, this.price, this.description);
}

class ResultsScreen extends StatelessWidget {
  final String origin;
  final String dest;

  const ResultsScreen({Key? key, required this.origin, required this.dest}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<TripData> trips = const [
      TripData('CTM', '08:30 ص', '140 درهم', 'حافلة ممتازة - خط مباشر'),
      TripData('Supratours', '10:15 ص', '130 درهم', 'حافلة مكيفة مريحة'),
      TripData('CTM VIP (خط الملعب)', '02:00 م', '170 درهم', 'مباشر للملعب الكبير ⚽'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text('$origin ⬅️ $dest'),
        backgroundColor: const Color(0xFFC62828),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(trip.company, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
              subtitle: Text('${trip.time} - ${trip.description}'),
              trailing: Text(trip.price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('تأكيد حجز ${trip.company}'),
                    content: Text('الرحلة نحو وجهتك جاهزة.\nرقم مرجع الحجز المؤقت: SIR-${DateTime.now().millisecond}\n\nسير سير نحو الملعب! 🇲🇦'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تأكيد الحجز بنجاح! طريقتنا سلامة.')),
                          );
                        },
                        child: const Text('تأكيد الحجز النهائي', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class StadiumAlertsScreen extends StatelessWidget {
  const StadiumAlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رادار رحلات الملاعب ⚽'),
        backgroundColor: const Color(0xFFC62828),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [
          Card(
            color: Colors.red,
            child: ListTile(
              leading: Icon(Icons.stadium, color: Colors.white, size: 30),
              title: Text('مركب محمد الخامس - الدار البيضاء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('رحلات مكثفة لـ CTM متوفرة لمباراة يوم السبت.', style: TextStyle(color: Colors.white70)),
            ),
          ),
          SizedBox(height: 8),
          Card(
            color: Colors.green,
            child: ListTile(
              leading: Icon(Icons.stadium, color: Colors.white, size: 30),
              title: Text('ملعب ابن بطوطة - طنجة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Text('خطوط خاصة تنطلق قبل اللقاء بـ 4 ساعات.', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
