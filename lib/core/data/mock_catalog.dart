import '../../features/achievements/domain/entities/achievement.dart';
import '../../features/gallery/domain/entities/gallery_album.dart';
import '../../features/home/domain/entities/news_item.dart';
import '../../features/quiz/domain/entities/quiz.dart';
import '../theme/app_assets.dart';

/// بيانات تجريبية إلى أن تُربط واجهات الـ API.
///
/// لا يستوردها إلا مصادر البيانات التجريبية في `features/*/data/datasources/`؛
/// الصفحات والـ Cubits تصل إلى البيانات عبر الـ UseCases فقط.
abstract final class MockCatalog {
  /// زمن الاستجابة المحاكى لطلبات الشبكة.
  static const latency = Duration(milliseconds: 250);

  static const news = [
    NewsItem(
      id: 'nw1',
      title: 'انطلاق التسجيل للفصل الدراسي الجديد',
      imageUrl: 'https://picsum.photos/seed/news1/800/400',
      date: 'منذ يومين',
    ),
    NewsItem(
      id: 'nw2',
      title: 'ورش تقوية مجانية في الرياضيات والعلوم',
      imageUrl: 'https://picsum.photos/seed/news2/800/400',
      date: 'منذ أسبوع',
    ),
  ];

  // أسئلة رياضيات مشتركة تُستخدم في اختبارات ونشاطات شاشة «اختباراتي».
  static const _mathQuestions = [
    QuizQuestion(
      id: 'm1',
      text: 'ما ناتج 7 × 8 ؟',
      options: ['54', '56', '58', '48'],
      correctIndex: 1,
    ),
    QuizQuestion(
      id: 'm2',
      text: 'ما قيمة x في المعادلة x + 5 = 12 ؟',
      options: ['5', '6', '7', '8'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'm3',
      text: 'مساحة مربع طول ضلعه 6 سم تساوي',
      options: ['12', '24', '36', '30'],
      correctIndex: 2,
    ),
    QuizQuestion(
      id: 'm4',
      text: 'أيّ الأعداد التالية عدد أوّلي؟',
      options: ['9', '15', '21', '13'],
      correctIndex: 3,
    ),
    QuizQuestion(
      id: 'm5',
      text: 'ناتج 144 ÷ 12 يساوي',
      options: ['12', '14', '11', '13'],
      correctIndex: 0,
    ),
  ];

  // بطاقات شاشة «اختباراتي»: تبويب «اختبارات» (kind=test) و«نشاطات يومية»
  // (kind=activity). كلاهما يفتح تدفق حل الأسئلة نفسه عند الضغط.
  static const quizzes = [
    // ── اختبارات ──
    Quiz(id: 'qt1', title: 'اختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.عمر النابلسي', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    Quiz(id: 'qt2', title: 'اختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    Quiz(id: 'qt3', title: 'اختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.أحمد الحفار', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    Quiz(id: 'qt4', title: 'اختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    // ── نشاطات يومية ──
    Quiz(id: 'qa1', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.عمر النابلسي', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
    Quiz(id: 'qa2', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
    Quiz(id: 'qa3', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.أحمد الحفار', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
    Quiz(id: 'qa4', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
  ];

  static const achievements = [
    Achievement(id: 'a1', title: 'أول خطوة', subtitle: 'أكمل أول درس', unlocked: true),
    Achievement(id: 'a2', title: 'مثابر', subtitle: 'تعلّم 7 أيام متتالية', unlocked: true),
    Achievement(id: 'a3', title: 'عالم القانون', subtitle: 'أنهِ دورة قانونية', unlocked: false),
    Achievement(id: 'a4', title: 'ممتاز', subtitle: 'احصل على 90% في اختبار', unlocked: false),
  ];

  // ألبومات المعرض (تطابق تصميم فيجما: الاسم + عدد الصور بين قوسين).
  // لكل ألبوم ترتيب [order] مختلف على صور AppAssets.galleryPhotos الست، بحيث
  // يبدأ كل ألبوم بغلاف مختلف ولا تتكرر صورتان متتاليتان.
  static final List<GalleryAlbum> galleryAlbums = [
    _album('gal_works', 'ألبوم الأعمال', 12, order: [0, 1, 2, 3, 4, 5]),
    _album('gal_drawing', 'ألبوم الرسم', 9, order: [1, 2, 3, 4, 5, 0]),
    _album('gal_math', 'ألبوم الرياضيات', 7, order: [2, 3, 4, 5, 0, 1]),
    _album('gal_science', 'ألبوم العلوم', 12, order: [3, 4, 5, 0, 1, 2]),
    _album('gal_stats', 'ألبوم الاحصاء', 6, order: [4, 5, 0, 1, 2, 3]),
    _album('gal_algebra', 'ألبوم الجبر', 7, order: [5, 0, 1, 2, 3, 4]),
  ];

  /// يبني ألبوماً بعدد [count] صورة، بترتيب [order] (فهارس ضمن
  /// [AppAssets.galleryPhotos]) يُكرَّر عند الحاجة لملء العدد المطلوب.
  static GalleryAlbum _album(String id, String title, int count, {required List<int> order}) {
    final pool = AppAssets.galleryPhotos;
    final photos = [for (var i = 0; i < count; i++) pool[order[i % order.length]]];
    return GalleryAlbum(id: id, title: title, cover: photos.first, photos: photos);
  }
}
