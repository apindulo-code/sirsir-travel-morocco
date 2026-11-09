# إعداد Firebase لتطبيق SirSir Travel Morocco

## الإعدادات المسجلة

- مشروع Firebase: `sirsir-travel-morocco`.
- رقم المشروع: `881046533648`.
- تطبيق Android: `ma.sirsirtravel.morocco`.
- تطبيق Web: `SirSir Travel Morocco Web`.
- إعدادات Android وWeb موجودة في `lib/firebase_options.dart` ويختار التطبيق إعداد المنصة تلقائياً.
- Cloud Firestore: قاعدة `(default)` في `europe-west1`، وضع الإنتاج.
- Authentication: تم تفعيل Email/Password وPhone وفق الإعدادات التي راجعها مالك المشروع؛ يجب إعادة التحقق واختبار SMS حقيقي قبل الإطلاق.

## ما هو جاهز في المستودع

- Firebase Core وAuthentication وCloud Firestore في تطبيق Flutter.
- التسجيل والدخول بالبريد، التحقق من البريد، إعادة تعيين كلمة المرور، والتحقق الهاتفي عبر SMS.
- خدمات ملفات المستخدمين وطلبات السفر والتقييمات.
- قواعد Firestore في `firestore.rules` وملف إعداد Firebase CLI.
- اختبارات قواعد الأمان عبر Firestore Emulator في GitHub Actions.
- نشر سابق موثق لقواعد Firestore في الإنتاج (run `42424468166`) ونجاح اختبارات المحاكي (run `42438516026`).

## شهادة توقيع Android التي تم التحقق منها — 9 نوفمبر 2026

تم تنزيل AAB الناتج من GitHub Actions run **#156** وفحص شهادة توقيعه محلياً باستخدام أدوات Java. ملف AAB يحمل توقيعاً صالحاً وفق فحص JAR، وشهادة الرفع صالحة حتى 26 مارس 2054. اسم الحزمة الذي ظهر داخل Manifest هو `ma.sirsirtravel.morocco`.

أضف بصمات شهادة التوقيع التالية إلى Firebase Console ← Project settings ← Your apps ← تطبيق Android ← SHA certificate fingerprints، خصوصاً لتدفق تسجيل الدخول عبر الهاتف:

- SHA-1: `E1:3C:27:E4:67:AB:01:81:EE:75:C6:94:4F:83:6C:80:BE:FB:ED:72`
- SHA-256: `1A:B0:EF:69:E5:EB:AA:5B:7A:3A:D6:84:53:4A:B5:07:3D:08:1F:FA:82:1A:6B:36:07:BA:F5:BA:0B:94:8F:FA`

هذه بصمات عامة للشهادة وليست المفتاح الخاص. لا ترفع ملف keystore ولا كلمات مروره إلى المستودع أو المحادثة. تأكد من حفظ نسخة احتياطية مشفرة من ملف keystore في مكانين آمنين؛ لم يتم التحقق من وجود النسخ الاحتياطية.

## ما تبقى قبل الإطلاق

1. **التحقق من WIF:** تأكد في Google Cloud من أن شرط Provider CEL محفوظ حرفياً كما يلي:
   ```cel
   assertion.repository == "apindulo-code/sirsir-travel-morocco" && assertion.ref == "refs/heads/main"
   ```
   يجب استخدام `==` في المقارنتين. Provider ID هو `github`، وPool ID هو `sirsir-github`.
2. **اختبار نشر القواعد:** شغّل يدوياً GitHub Actions > Deploy Firebase Firestore Rules، وتحقق من نجاح كل الخطوات قبل اعتبار الربط مكتملاً.
3. **فهرسة الاستعلامات:** `firestore.indexes.json` لا يحتوي حالياً على فهارس مركبة؛ أضف فقط ما تطلبه أخطاء الاستعلامات الفعلية.
4. **اختبار الحسابات:** اختبر البريد والتحقق وإعادة تعيين كلمة المرور. اختبر SMS حقيقياً برقم تملكه؛ أرقام الاختبار لا تثبت وصول الرسائل الحقيقية.
5. **الفوترة وSMS:** لا تفعّل خطة مدفوعة أو فوترة قبل مراجعة الأسعار والموافقة الصريحة. قد لا يعمل SMS الحقيقي في الخطة الحالية.
6. **اختبار الويب:** تحقق من النطاقات المسموح بها في Authentication > Settings > Authorized domains.
7. **اختبار الحجز:** تحقق من حفظ الطلب وظهوره لصاحبه فقط وإمكانية إلغائه. الطلب داخل التطبيق ليس تذكرة مؤكدة لدى شركة النقل.
8. **الخصوصية والإطلاق:** راجع سياسة الخصوصية وشروط الاستخدام وبيانات التواصل والدعم مع مختص قبل النشر العام.

## الأمان

- لا تضع كلمات مرور أو مفاتيح Service Account أو ملفات JSON الخاصة بالخادم في GitHub.
- إعدادات Firebase الخاصة بتطبيق العميل ليست أسرار خادم؛ حماية البيانات تعتمد على قواعد Firestore وصحة إعدادات Authentication.
- لا تفعّل فوترة أو خطة مدفوعة أو خدمات SMS برسوم دون مراجعة التكلفة والموافقة.
- محتوى الوجهات والأخبار ومزودي النقل للقراءة العامة فقط من التطبيق؛ يجب أن تأتي الكتابة من قناة إدارية موثوقة.
- حساب الخدمة المخصص للنشر: `sirsir-github-deploy@sirsir-travel-morocco.iam.gserviceaccount.com`. الدور المطلوب لنشر القواعد: Firebase Rules Admin، مع Workload Identity User على حساب الخدمة.

## حدود المنتج الحالية

- طلب الحجز هو طلب داخلي محفوظ في Firestore، وليس حجزاً مؤكداً أو إصدار تذكرة.
- الأسعار والجداول ليست بيانات ناقلين مباشرة ما لم يتم ربط مزود رسمي.
- بيانات الطقس والبحر تقديرية وليست تحذيراً رسمياً أو ضماناً للسلامة.
- معلومات ملاعب 2030 يجب تحديثها وفق الإعلانات الرسمية.

## أتمتة النشر من GitHub

ملف `.github/workflows/firebase-deploy-rules.yml` يستخدم الآن Workload Identity Federation، ولا يحتاج إلى Service Account JSON أو GitHub Secret. يبدأ تلقائياً عند كل push إلى الفرع `main`، ويمكن أيضاً تشغيله يدوياً عبر `workflow_dispatch`. ينشر Firestore Rules فقط إلى مشروع `sirsir-travel-morocco`.

إعداد المصادقة في Workflow:

- Pool: `sirsir-github`
- Provider: `github`
- Provider resource: `projects/881046533648/locations/global/workloadIdentityPools/sirsir-github/providers/github`
- Service account: `sirsir-github-deploy@sirsir-travel-morocco.iam.gserviceaccount.com`
- GitHub repository condition: `apindulo-code/sirsir-travel-morocco`
- Branch condition: `refs/heads/main`

رابط التشغيل: https://github.com/apindulo-code/sirsir-travel-morocco/actions/workflows/firebase-deploy-rules.yml

هذا الـWorkflow لا ينشر Hosting أو Storage، ولا يفعّل الفوترة، ولا يرسل SMS. لا تعتبر عملية النشر مكتملة حتى يظهر تشغيل أخضر ناجح في GitHub Actions.
