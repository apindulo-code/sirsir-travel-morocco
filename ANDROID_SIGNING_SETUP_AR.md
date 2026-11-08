# إعداد توقيع Android بأمان — SirSir Travel Morocco

هذه الخطوات مطلوبة فقط لإنتاج ملف Android App Bundle (AAB) موقّع صالح لرفعه إلى Google Play. لا ترسل ملف keystore أو كلمات المرور أو محتوى الأسرار في المحادثة، ولا تضعها في GitHub repository files.

## 1. إنشاء مفتاح الرفع على جهاز موثوق

ثبّت Android Studio أو JDK حديثاً، ثم نفّذ:

```bash
keytool -genkeypair -v -keystore sirsir-upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias sirsir-upload
```

- اختر كلمة مرور قوية لمخزن المفاتيح.
- اختر كلمة مرور للمفتاح (يمكن أن تكون مختلفة).
- احتفظ بملف `sirsir-upload-keystore.jks` ونسخة احتياطية مشفرة في مكانين آمنين.
- لا تفقد المفتاح؛ فقدان مفتاح الرفع قد يعقّد تحديث التطبيق.

## 2. تحويل keystore إلى Base64

Linux:
```bash
base64 -w 0 sirsir-upload-keystore.jks
```

macOS:
```bash
base64 < sirsir-upload-keystore.jks | tr -d '\\n'
```

PowerShell:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("sirsir-upload-keystore.jks"))
```

انسخ الناتج مباشرة إلى GitHub Secret، ولا ترسله إلى أي شخص.

## 3. إضافة GitHub Actions Secrets

افتح المستودع:
https://github.com/apindulo-code/sirsir-travel-morocco

ثم Settings → Secrets and variables → Actions → New repository secret، وأضف الأسماء التالية:

| Secret name | القيمة |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | نص Base64 الكامل |
| `ANDROID_KEY_ALIAS` | `sirsir-upload` |
| `ANDROID_STORE_PASSWORD` | كلمة مرور keystore |
| `ANDROID_KEY_PASSWORD` | كلمة مرور المفتاح |

لا تضع هذه القيم في Variables العادية ولا في ملفات المشروع أو Issues أو المحادثة.

## 4. ما الذي يلزم بعد ذلك؟

بعد حفظ الأسرار، يلزم تشغيل مسار بناء AAB الموقّع في GitHub Actions والتحقق من أن ملف `.aab` الناتج موقّع فعلاً. إعداد الأسرار وحده لا ينشئ AAB ولا يرفعه إلى Google Play.

## 5. إعدادات Firebase بعد التوقيع

بعد إنشاء شهادة التوقيع، استخرج SHA-1 وSHA-256:

```bash
keytool -list -v -keystore sirsir-upload-keystore.jks -alias sirsir-upload
```

أضف بصمتي SHA-1 وSHA-256 إلى إعدادات تطبيق Android في Firebase، ثم أعد تنزيل/تحديث إعدادات Firebase إذا لزم الأمر، واختبر تسجيل الدخول عبر الهاتف وSMS على جهاز حقيقي.

**تنبيه:** لا ترفع ملف keystore إلى GitHub، حتى لو كان المستودع خاصاً. لا تحفظه ضمن Artifacts ولا تشاركه في البريد أو المحادثات.
