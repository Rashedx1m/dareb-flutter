/// مسارات الصور والأيقونات المضمّنة في المشروع (assets).
/// الرسوم المتجهة (SVG) تُعرض عبر flutter_svg، والصور النقطية عبر Image.asset.
abstract final class AppAssets {
  // صور توضيحية.
  static const studentWriting = 'assets/images/student_writing.png';

  // أيقونات متجهة (SVG).
  static const icNotification = 'assets/icons/notification_filled.svg';
  static const icSealCheck = 'assets/icons/seal_check_fill.svg';
  static const logo = 'assets/icons/Group.svg';
  // رمز الشعار وحده (الكتاب والأوراق بلا كلمة «درب») كما في ترويسات التصميم،
  // ونسخته بألوان التطبيق (كتاب فيروزي وأوراق زرقاء) للخلفيات البيضاء.
  static const logoMark = 'assets/icons/logo_mark.svg';
  static const logoColor = 'assets/icons/logo_color.svg';
  static const icQuiz = 'assets/icons/ic_quiz.svg'; // أيقونة بطاقة الاختبار (لوح + ؟)
  static const icActivity = 'assets/icons/ic_activity.svg'; // أيقونة النشاط اليومي (رأس + دمبل)
}
