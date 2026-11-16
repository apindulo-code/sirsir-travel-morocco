import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HajjUmrahScreen extends StatelessWidget {
  const HajjUmrahScreen({super.key, this.language = 'ar'});

  final String language;

  String _text(String ar, String en, String fr, String es) {
    switch (language) {
      case 'en':
        return en;
      case 'fr':
        return fr;
      case 'es':
        return es;
      default:
        return ar;
    }
  }

  Future<void> _openOfficialSite(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_text(
            'تعذر فتح الموقع الرسمي. تحقق من الاتصال بالإنترنت.',
            'Could not open the official website. Check your internet connection.',
            'Impossible d’ouvrir le site officiel. Vérifiez votre connexion.',
            'No se pudo abrir el sitio oficial. Comprueba tu conexión.',
          )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = <_GuideSection>[
      _GuideSection(
        title: _text('الاستعداد والإحرام', 'Preparation and Ihram', 'Préparation et Ihram', 'Preparación e Ihram'),
        icon: Icons.checklist,
        points: [
          _text('التحقق من جواز السفر والتأشيرة والتصاريح والتعليمات الصحية السارية.', 'Check passport, visa, permits and current health instructions.', 'Vérifiez le passeport, le visa, les autorisations et les consignes sanitaires en vigueur.', 'Comprueba el pasaporte, visado, permisos e instrucciones sanitarias vigentes.'),
          _text('معرفة الميقات المناسب لمسار الرحلة قبل تجاوزه.', 'Identify the correct Miqat for your route before passing it.', 'Identifiez le Miqat adapté à votre itinéraire avant de le dépasser.', 'Identifica el Miqat correspondiente a tu ruta antes de pasarlo.'),
          _text('الاغتسال ولباس الإحرام والنية والتلبية وفق الدليل الشرعي المعتمد.', 'Prepare Ihram clothing, intention and Talbiyah according to an authoritative guide.', 'Préparez la tenue d’Ihram, l’intention et la Talbiya selon un guide religieux reconnu.', 'Prepara la vestimenta de Ihram, la intención y la Talbiya según una guía religiosa autorizada.'),
        ],
      ),
      _GuideSection(
        title: _text('مناسك العمرة', 'Umrah rites', 'Rites de la Omra', 'Ritos de la Umrah'),
        icon: Icons.mosque,
        points: [
          _text('الإحرام من الميقات المحدد للمسافر.', 'Enter Ihram at the designated Miqat.', 'Entrez en état d’Ihram au Miqat désigné.', 'Entra en estado de Ihram en el Miqat indicado.'),
          _text('الطواف حول الكعبة سبعة أشواط، مع اتباع المسار والتعليمات التنظيمية.', 'Perform seven circuits around the Kaaba, following crowd-control instructions.', 'Effectuez sept tours autour de la Kaaba en respectant les consignes de circulation.', 'Realiza siete vueltas alrededor de la Kaaba siguiendo las instrucciones de circulación.'),
          _text('السعي بين الصفا والمروة سبعة أشواط، ثم الحلق أو التقصير.', 'Perform seven circuits between Safa and Marwah, then shave or trim the hair.', 'Effectuez sept parcours entre Safa et Marwa, puis rasez ou raccourcissez les cheveux.', 'Realiza siete recorridos entre Safa y Marwa y después afeita o recorta el cabello.'),
        ],
      ),
      _GuideSection(
        title: _text('مناسك الحج باختصار', 'Hajj rites at a glance', 'Rites du Hajj en bref', 'Ritos del Hajj en resumen'),
        icon: Icons.calendar_month,
        points: [
          _text('أعمال يوم التروية في منى وفق النسك والبرنامج المعتمد.', 'Mina activities on the Day of Tarwiyah according to the approved Hajj schedule.', 'Les rites à Mina le jour de Tarwiya selon le programme du Hajj approuvé.', 'Actividades en Mina el día de Tarwiyah según el programa aprobado del Hajj.'),
          _text('الوقوف بعرفة في اليوم المحدد، ثم الإفاضة إلى مزدلفة وفق التعليمات.', 'Stand at Arafat on the designated day, then proceed to Muzdalifah as instructed.', 'Stationnez à Arafat le jour prévu, puis rejoignez Muzdalifah selon les consignes.', 'Permanece en Arafat el día indicado y después dirígete a Muzdalifah según las instrucciones.'),
          _text('رمي الجمرات والهدي والحلق أو التقصير وطواف الإفاضة وفق ترتيب النسك والفتوى المعتمدة.', 'Complete the Jamarat, sacrifice, shaving or trimming, and Tawaf al-Ifadah according to the approved rites and guidance.', 'Accomplissez les rites de Jamarat, le sacrifice, la coupe des cheveux et le Tawaf al-Ifadah selon les rites et avis reconnus.', 'Completa los ritos de Jamarat, sacrificio, corte de cabello y Tawaf al-Ifadah según los ritos y orientación autorizados.'),
        ],
      ),
      _GuideSection(
        title: _text('قائمة المسافر المغربي', 'Moroccan traveller checklist', 'Liste du voyageur marocain', 'Lista del viajero marroquí'),
        icon: Icons.luggage,
        points: [
          _text('احتفظ بنسخ آمنة من وثائق السفر والتأشيرة والتصاريح وتفاصيل السكن والنقل.', 'Keep secure copies of travel documents, visa, permits, accommodation and transport details.', 'Conservez des copies sécurisées des documents de voyage, visa, autorisations, hébergement et transport.', 'Guarda copias seguras de documentos de viaje, visado, permisos, alojamiento y transporte.'),
          _text('احتفظ بأدوية الاستخدام الشخصي في عبواتها الأصلية، وتحقق من قواعد إدخالها.', 'Keep personal medicines in original packaging and check import rules.', 'Gardez vos médicaments personnels dans leur emballage d’origine et vérifiez les règles d’importation.', 'Conserva tus medicamentos personales en sus envases originales y consulta las normas de entrada.'),
          _text('اتفق مع المجموعة على نقطة تجمع وخطة تواصل عند الازدحام أو فقدان الاتصال.', 'Agree on a meeting point and communication plan in case of crowds or lost contact.', 'Convenez d’un point de rendez-vous et d’un plan de communication en cas d’affluence ou de perte de contact.', 'Acuerda un punto de encuentro y un plan de comunicación en caso de aglomeraciones o pérdida de contacto.'),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_text('فضاء الحج والعمرة', 'Hajj and Umrah', 'Espace Hajj et Omra', 'Espacio Hajj y Umrah')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _text(
                  'دليل توعوي للمسافر المغربي. قد تتغير الإجراءات والمواعيد والمتطلبات؛ اعتمد دائماً على التعليمات الرسمية والمرشد الديني المعتمد.',
                  'An informational guide for Moroccan travellers. Procedures, dates and requirements may change; always follow official instructions and qualified religious guidance.',
                  'Guide informatif pour les voyageurs marocains. Les procédures, dates et exigences peuvent changer ; suivez toujours les instructions officielles et les conseils religieux qualifiés.',
                  'Guía informativa para viajeros marroquíes. Los procedimientos, fechas y requisitos pueden cambiar; sigue siempre las instrucciones oficiales y la orientación religiosa cualificada.',
                ),
                style: const TextStyle(height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...sections.map(
            (section) => Card(
              child: ExpansionTile(
                leading: Icon(section.icon, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: section.points
                    .map(
                      (point) => Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(18, 4, 18, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(child: Text(point, style: const TextStyle(height: 1.45))),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _text('المصادر الرسمية', 'Official resources', 'Sources officielles', 'Fuentes oficiales'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('وزارة الحج والعمرة السعودية'),
              subtitle: const Text('haj.gov.sa'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openOfficialSite(context, 'https://www.haj.gov.sa/'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.travel_explore),
              title: const Text('Nusuk'),
              subtitle: const Text('nusuk.sa'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _openOfficialSite(context, 'https://www.nusuk.sa/'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              'هذه المعلومات عامة ولا تستبدل الفتوى أو الدليل الرسمي الخاص بموسم الحج أو العمرة.',
              'This general information does not replace a religious ruling or the official guide for the current Hajj or Umrah season.',
              'Ces informations générales ne remplacent ni un avis religieux ni le guide officiel de la saison en cours.',
              'Esta información general no sustituye una opinión religiosa ni la guía oficial de la temporada actual.',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _GuideSection {
  const _GuideSection({
    required this.title,
    required this.icon,
    required this.points,
  });

  final String title;
  final IconData icon;
  final List<String> points;
}
