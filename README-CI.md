# LinkPlayer — بناء IPA عبر GitHub Actions (باستعمال شهادتك)

هذه الحزمة تحوّل كود LinkPlayer v2 (محرك VLC) إلى IPA حقيقي
على سحابة GitHub، باستعمال شهادتك أنت. لا حاجة إلى Mac.

## قبل الدفع: 3 قيم لازم تطابق شهادتك

1. في `LinkPlayer.xcodeproj/project.pbxproj`: بدّل
   `com.example.linkplayer` بالـ Bundle ID تاع الـ provisioning profile تاعك.
2. في `ExportOptions.plist`: بدّل `TEAMID` (معرّف فريق Apple، 10 حروف)،
   ونفس الـ Bundle ID، و`PROFILE_NAME` (اسم البروفايل كما يظهر في Xcode
   أو حساب Apple Developer — أو الـ UUID تاعه).
3. إذا شهادتك **Development** (مش Distribution): بدّل `method` إلى
   `development` في `ExportOptions.plist`، و`CODE_SIGN_IDENTITY`
   إلى `Apple Development` في `.github/workflows/ios.yml`.

## الخطوات

1. أنشئ مستودع GitHub جديد وادفع كل ملفات هذا المجلد إليه
   (المستودع Public أسهل: دقائق macOS مجانية بلا حدود تقريباً.
   إذا كان Private فالدقائق محدودة والبناء الأول يطول).
2. في GitHub: Settings → Secrets and variables → Actions →
   New repository secret، وأضف الثلاثة بنفسك (لا ترسلها أبداً في محادثة):
   - `APPLE_CERTIFICATE_BASE64`: ملف الشهادة `.p12` مشفّراً بـ base64
     (على Mac: `base64 -i cert.p12 | pbcopy`).
   - `APPLE_CERTIFICATE_PASSWORD`: كلمة سر ملف `.p12`.
   - `PROVISIONING_PROFILE_BASE64`: ملف `.mobileprovision` مشفّراً بـ base64.
   - ملاحظة: الـ IPA ad-hoc يثبت فقط على الأجهزة المسجلة في البروفايل.
3. Actions → Build IPA → Run workflow.
4. بعد انتهاء البناء: حمّل الـ IPA من Artifacts (اسمها `LinkPlayer-ipa`).

## ملاحظات صريحة

- البناء الأول يطول (تحميل MobileVLCKit وحده يقارب 100MB+).
- مشروع Xcode هنا مكتوب يدوياً ولم يُجرَّب بناؤه (لا يوجد Xcode
  في بيئة العمل)؛ أول بناء في GitHub هو الاختبار الحقيقي.
  إذا ظهر خطأ بناء، أرسل لي رسالته كاملة وسأصلحه.
- الشهادة والمفتاح الخاص لا يمران بي أبداً: أنت تضعهما كـ secrets
  في GitHub مباشرة، والـ runner يستعملهما ويمسح ملف الشهادة بعد الاستيراد.
