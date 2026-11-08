# تفعيل صفحات الموقع القانوني — SirSir Travel Morocco

تم تجهيز ملفات الموقع داخل مجلد `docs/` على الفرع `main`. لتفعيل الرابط العام، يلزم إجراء إعداد واحد من مالك المستودع:

1. افتح المستودع: https://github.com/apindulo-code/sirsir-travel-morocco
2. افتح **Settings**.
3. من القائمة الجانبية اختر **Pages**.
4. في **Build and deployment** اجعل **Source** = **Deploy from a branch**.
5. اختر **Branch** = `main`، واختر المجلد `/docs`.
6. اضغط **Save**.
7. انتظر اكتمال النشر، ثم افتح:
   https://apindulo-code.github.io/sirsir-travel-morocco/

## الروابط بعد نجاح النشر

- الصفحة الرئيسية: https://apindulo-code.github.io/sirsir-travel-morocco/
- سياسة الخصوصية: https://apindulo-code.github.io/sirsir-travel-morocco/privacy-policy/
- شروط الاستخدام: https://apindulo-code.github.io/sirsir-travel-morocco/terms/
- حذف الحساب: https://apindulo-code.github.io/sirsir-travel-morocco/delete-account/

**مهم:** هذه الروابط متوقعة وفق اسم المستودع، وليست مؤكدة حتى يظهر نجاح GitHub Pages ويفتح كل رابط دون خطأ. لا تدخل رابط حذف الحساب في Google Play Console قبل اختباره من متصفح خارج حساب GitHub.

## قبل الإطلاق العام

- استكمل العنوان البريدي لمسؤول التطبيق وتاريخ نفاذ الوثائق.
- اعتمد مدد معالجة طلبات الحذف والاحتفاظ بالبيانات والنسخ الاحتياطية.
- راجع SDKs الفعلية وإعدادات التحليلات وتقارير الأعطال والإعلانات قبل تعبئة Data safety.
- احصل على مراجعة مختص مغربي لحماية المعطيات، خصوصاً نقل البيانات إلى منطقة Firestore في بلجيكا وإجراءات CNDP.
- اختبر رابط الحذف خارج التطبيق وتأكد من أن البريد الإلكتروني يستقبل الطلبات ويُعالجها فعلياً.
