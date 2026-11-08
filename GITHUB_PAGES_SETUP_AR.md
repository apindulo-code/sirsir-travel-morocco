# نشر الموقع القانوني — SirSir Travel Morocco

تم إعداد نشر آلي باستخدام GitHub Actions. يوجد ملف سير العمل:
`.github/workflows/deploy-legal-site.yml`
وهو يبني صفحات Markdown العربية داخل `docs/` ثم ينشرها إلى GitHub Pages عند تحديث الوثائق في الفرع `main`.

## الإعداد الأولي المطلوب من مالك المستودع

1. افتح المستودع: https://github.com/apindulo-code/sirsir-travel-morocco
2. افتح **Settings** ثم **Pages**.
3. تحت **Build and deployment** اجعل **Source** = **GitHub Actions**.
4. احفظ التغيير إن ظهر زر **Save**.
5. افتح تبويب **Actions** ثم سير العمل **Deploy legal website to GitHub Pages**.
6. تحقق من أن آخر تشغيل انتهى بحالة خضراء **Success**.
7. افتح رابط **Visit site** من إعدادات Pages أو رابط الموقع أدناه، واختبر الصفحات الأربع من متصفح عادي.

## روابط الموقع المتوقعة بعد نجاح النشر

- الصفحة الرئيسية: https://apindulo-code.github.io/sirsir-travel-morocco/
- سياسة الخصوصية: https://apindulo-code.github.io/sirsir-travel-morocco/privacy-policy/
- شروط الاستخدام: https://apindulo-code.github.io/sirsir-travel-morocco/terms/
- حذف الحساب: https://apindulo-code.github.io/sirsir-travel-morocco/delete-account/

**مهم:** هذه الروابط مبنية على اسم المستودع، ولا تُعد روابط منشورة ومؤكدة حتى ينجح سير العمل ويظهر الموقع في GitHub Pages. لا تضع رابط حذف الحساب في Google Play Console قبل فتحه واختباره من متصفح خارج حساب GitHub والتأكد من أن البريد يستقبل الطلبات ويعالجها فعلياً.

## ما يجب استكماله قبل الإطلاق العام

- استكمال العنوان البريدي لمسؤول التطبيق وتاريخ نفاذ الوثائق.
- اعتماد مدد معالجة طلبات الحذف والاحتفاظ بالبيانات والنسخ الاحتياطية.
- مراجعة SDKs الفعلية وإعدادات التحليلات وتقارير الأعطال والإعلانات قبل تعبئة Data safety.
- مراجعة مختص مغربي لحماية المعطيات، خصوصاً نقل البيانات إلى منطقة Firestore في بلجيكا وإجراءات CNDP.
- اختبار تسجيل الحساب بالبريد والهاتف على جهاز Android حقيقي.
- إنشاء مفتاح توقيع Android وحفظ نسخة احتياطية آمنة منه، ثم إعداد أسرار GitHub لإنتاج AAB موقّع.
- اختبار الحذف من داخل التطبيق وخارجه، بما في ذلك الطلبات والتقييمات وسجلات Firebase.

