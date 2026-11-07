import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Sign-in screen. Email/password and SMS are available when their providers
/// are enabled in the linked Firebase project.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _smsCode = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _phoneMode = false;
  bool _codeSent = false;
  String? _verificationId;
  int? _resendToken;

  void _message(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'user-not-found':
      case 'invalid-credential': return 'بيانات الدخول غير صحيحة.';
      case 'wrong-password': return 'كلمة المرور غير صحيحة.';
      case 'email-already-in-use': return 'هذا البريد مسجل مسبقاً.';
      case 'weak-password': return 'اختر كلمة مرور من 6 أحرف على الأقل.';
      case 'too-many-requests': return 'محاولات كثيرة. حاول لاحقاً.';
      case 'operation-not-allowed': return 'طريقة التسجيل غير مفعلة في إعدادات Firebase.';
      case 'invalid-phone-number': return 'رقم الهاتف غير صحيح. استخدم مفتاح الدولة مثل +212.';
      case 'quota-exceeded': return 'تم بلوغ حد رسائل التحقق. حاول لاحقاً.';
      default: return error.message ?? 'تعذر إتمام العملية. تحقق من الإعدادات والإنترنت.';
    }
  }

  Future<void> _emailSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = AuthService();
      if (_register) {
        final result = await auth.registerWithEmail(
          email: _email.text,
          password: _password.text,
        );
        if (result.user != null) {
          try {
            await FirestoreService().saveCurrentUserProfile(
              displayName: _name.text.trim(),
              preferredLanguage: 'ar',
            );
          } catch (_) {}
        }
        _message('تم إنشاء الحساب. تحقق من بريدك الإلكتروني لتأكيده.');
      } else {
        await auth.signInWithEmail(email: _email.text, password: _password.text);
        try {
          await FirestoreService().saveCurrentUserProfile();
        } catch (_) {}
        _message('مرحباً بعودتك.');
      }
    } on FirebaseAuthException catch (e) {
      _message(_friendlyError(e));
    } catch (_) {
      _message('حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() async {
    if (_phone.text.trim().isEmpty) {
      _message('أدخل رقم الهاتف مع مفتاح الدولة، مثال: +212600000000');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService().verifyPhoneNumber(
        phoneNumber: _phone.text,
        onVerificationCompleted: (credential) async {
          try {
            await AuthService().signInWithPhoneCredential(credential);
            if (mounted) _message('تم التحقق من رقم الهاتف وتسجيل الدخول.');
          } catch (e) {
            if (mounted) _message('تعذر إكمال تسجيل الدخول بهذا الرقم.');
          }
        },
        onVerificationFailed: (error) {
          if (mounted) _message(_friendlyError(error));
        },
        onCodeSent: (id, token) {
          if (!mounted) return;
          setState(() {
            _verificationId = id;
            _resendToken = token;
            _codeSent = true;
          });
          _message('تم إرسال رمز التحقق عبر SMS.');
        },
        onCodeAutoRetrievalTimeout: (id) {
          _verificationId = id;
        },
      );
    } on FirebaseAuthException catch (e) {
      _message(_friendlyError(e));
    } catch (_) {
      _message('تعذر إرسال الرمز. تحقق من رقم الهاتف وإعدادات Firebase.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _smsCode.text.trim().length < 6) {
      _message('أدخل رمز التحقق المكوّن من 6 أرقام.');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService().signInWithSmsCode(
        verificationId: _verificationId!,
        smsCode: _smsCode.text,
      );
      try {
        await FirestoreService().saveCurrentUserProfile();
      } catch (_) {}
      _message('تم تسجيل الدخول بنجاح.');
    } on FirebaseAuthException catch (e) {
      _message(_friendlyError(e));
    } catch (_) {
      _message('رمز التحقق غير صحيح أو انتهت صلاحيته.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty) {
      _message('أدخل بريدك الإلكتروني أولاً.');
      return;
    }
    try {
      await AuthService().sendPasswordReset(_email.text);
      _message('أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك.');
    } on FirebaseAuthException catch (e) {
      _message(_friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      initialData: AuthService().currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('حسابي')),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 38)),
                const SizedBox(height: 14),
                Text(user.displayName ?? user.email ?? user.phoneNumber ?? 'مستخدم SirSir',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                if (user.email != null) Text(user.email!, textAlign: TextAlign.center),
                if (user.phoneNumber != null) Text(user.phoneNumber!, textAlign: TextAlign.center),
                const SizedBox(height: 22),
                if (user.email != null && !user.emailVerified)
                  OutlinedButton(
                    onPressed: () async {
                      try { await user.sendEmailVerification(); _message('تم إرسال رسالة التحقق.'); }
                      catch (_) { _message('تعذر إرسال رسالة التحقق.'); }
                    },
                    child: const Text('إعادة إرسال تأكيد البريد'),
                  ),
                FilledButton.icon(
                  onPressed: _busy ? null : () async {
                    await AuthService().signOut();
                    if (mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: _busy ? null : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('حذف الحساب نهائياً؟'),
                        content: const Text('سيتم حذف ملفك الشخصي وطلبات الحجز المرتبطة بحسابك. لا يمكن التراجع عن هذه العملية.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext, false),
                            child: const Text('إلغاء'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('حذف الحساب'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !mounted) return;
                    setState(() => _busy = true);
                    try {
                      await FirestoreService().deleteCurrentUserDataAndAccount();
                      _message('تم حذف الحساب وبيانات الحجوزات المرتبطة به.');
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'requires-recent-login') {
                        _message('لأمانك، سجّل الخروج ثم ادخل مجدداً قبل حذف الحساب.');
                      } else {
                        _message(_friendlyError(e));
                      }
                    } catch (_) {
                      _message('تعذر حذف الحساب. تحقق من قواعد Firestore ثم حاول مجدداً.');
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('حذف الحساب وبياناتي'),
                ),
                const SizedBox(height: 8),
                const Text('حذف الحساب يزيل ملف المستخدم وطلبات الحجز المحفوظة في SirSir. قد يتطلب Firebase تسجيل الدخول مجدداً للتحقق من الهوية.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('حساب SirSir')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(Icons.travel_explore, size: 58, color: Color(0xFFC62828)),
                const SizedBox(height: 8),
                const Text('أنشئ حسابك واحتفظ برحلاتك',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('تسجيل الدخول')),
                    ButtonSegment(value: true, label: Text('حساب جديد')),
                  ],
                  selected: {_register},
                  onSelectionChanged: (values) => setState(() => _register = values.first),
                ),
                const SizedBox(height: 16),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('البريد الإلكتروني')),
                    ButtonSegment(value: true, label: Text('رقم الهاتف')),
                  ],
                  selected: {_phoneMode},
                  onSelectionChanged: (values) => setState(() {
                    _phoneMode = values.first;
                    _codeSent = false;
                  }),
                ),
                const SizedBox(height: 16),
                if (_phoneMode) ...[
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف مع مفتاح الدولة',
                      hintText: '+212600000000',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _smsCode,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'رمز SMS',
                        prefixIcon: Icon(Icons.sms),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _busy ? null : (_codeSent ? _verifyCode : _sendCode),
                    child: Text(_busy ? 'يرجى الانتظار…' : (_codeSent ? 'تأكيد الرمز' : 'إرسال رمز التحقق')),
                  ),
                  if (_codeSent)
                    TextButton(onPressed: _busy ? null : _sendCode, child: const Text('إعادة إرسال الرمز')),
                ] else ...[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_register) ...[
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person)),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل اسمك.' : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email)),
                          validator: (v) => (v == null || !v.contains('@')) ? 'أدخل بريداً إلكترونياً صحيحاً.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock)),
                          validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور 6 أحرف على الأقل.' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _busy ? null : _emailSubmit,
                    child: Text(_busy ? 'يرجى الانتظار…' : (_register ? 'إنشاء الحساب' : 'دخول')),
                  ),
                  if (!_register)
                    TextButton(onPressed: _busy ? null : _resetPassword, child: const Text('نسيت كلمة المرور؟')),
                ],
                const SizedBox(height: 16),
                const Text('لن يتم إنشاء حجز نقل مؤكد إلا عبر منصة الناقل الرسمية. حساب SirSir مخصص لخدمات التطبيق وحفظ بياناتك.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    _smsCode.dispose();
    super.dispose();
  }
}
