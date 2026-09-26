/// مسارات الصور والأيقونات المضمّنة في المشروع (assets).
/// الرسوم المتجهة (SVG) تُعرض عبر flutter_svg، والصور النقطية عبر Image.asset.
abstract final class AppAssets {
  // صور توضيحية.
  static const studentWriting = 'assets/images/student_writing.png';
  static const subjectScience = 'assets/images/subject_science.png';
  static const subjectMath = 'assets/images/subject_math.png';
  static const subjectSocial = 'assets/images/subject_social.png';

  // أيقونات متجهة (SVG).
  static const icNotification = 'assets/icons/notification_filled.svg';
  static const icSealCheck = 'assets/icons/seal_check_fill.svg';
  static const logo = 'assets/icons/Group.svg';
  static const icQuiz = 'assets/icons/ic_quiz.svg'; // أيقونة بطاقة الاختبار (لوح + ؟)
  static const icActivity = 'assets/icons/ic_activity.svg'; // أيقونة النشاط اليومي (رأس + دمبل)

  // صور المعرض (ألبومات الطلاب) — صور حقيقية مقصوصة من التصميم، ست لقطات مختلفة.
  static const galleryPhotos = <String>[
    'assets/images/gallery/photo_1.png',
    'assets/images/gallery/photo_2.png',
    'assets/images/gallery/photo_3.png',
    'assets/images/gallery/photo_4.png',
    'assets/images/gallery/photo_5.png',
    'assets/images/gallery/photo_6.png',
  ];

  /// يربط مفتاح المادة (Category.icon) بالصورة التوضيحية المناسبة.
  static String? subjectImage(String key) => switch (key) {
        'science' => subjectScience,
        'math' => subjectMath,
        'social' => subjectSocial,
        _ => null,
      };
}
