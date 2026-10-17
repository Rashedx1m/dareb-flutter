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
      imageUrl: 'https://picsum.photos/seed/news1/800/400',
      link: 'https://www.google.com/',
    ),
    NewsItem(
      id: 'nw2',
      imageUrl: 'https://picsum.photos/seed/news2/800/400',
      link: 'https://www.google.com/',
    ),
  ];

  /// بطاقات «اختباراتي». العدّاد 20 يطابق التصميم؛ الأسئلة المعروضة ثلاثة.
  static const quizzes = [
    Quiz(id: '6', title: 'اختبار رياضيات', instructor: 'أ.عمر النابلسي', questionsCount: 20),
    Quiz(id: '7', title: 'نشاطات رياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, kind: QuizKind.activity),
  ];

  /// تفاصيل الحل والنتيجة. العدّادات 17/3 من 20 تعطي 85٪ كما في التصميم.
  static const quizDetails = <String, QuizDetails>{
    '6': QuizDetails(
      id: '6',
      title: 'اختبار رياضيات',
      questionsCount: 20,
      correctAnswers: 17,
      failedAnswers: 3,
      questions: [
        QuizQuestion(
          id: 'q1',
          text: 'ما هي عاصمة فرنسا؟',
          answers: [
            QuizAnswer(id: 'a11', text: 'مدريد', isCorrect: false),
            QuizAnswer(id: 'a12', text: 'باريس', isCorrect: true, isSelected: true),
            QuizAnswer(id: 'a13', text: 'روما', isCorrect: false),
          ],
        ),
        QuizQuestion(
          id: 'q2',
          text: 'أي كوكب يُعرف بالكوكب الأحمر؟',
          answers: [
            QuizAnswer(id: 'a21', text: 'المشتري', isCorrect: false, isSelected: true),
            QuizAnswer(id: 'a22', text: 'المريخ', isCorrect: true),
            QuizAnswer(id: 'a23', text: 'الزهرة', isCorrect: false),
          ],
        ),
        QuizQuestion(
          id: 'q3',
          text: 'كم عدد قارات العالم؟',
          answers: [
            QuizAnswer(id: 'a31', text: '5', isCorrect: false),
            QuizAnswer(id: 'a32', text: '6', isCorrect: false),
            QuizAnswer(id: 'a33', text: '7', isCorrect: true, isSelected: true),
          ],
        ),
      ],
    ),
    '7': QuizDetails(
      id: '7',
      title: 'نشاطات رياضيات',
      questionsCount: 20,
      correctAnswers: 17,
      failedAnswers: 3,
      questions: [
        QuizQuestion(
          id: 'q7',
          text: 'ما ناتج 7 × 8؟',
          answers: [
            QuizAnswer(id: 'a71', text: '54', isCorrect: false),
            QuizAnswer(id: 'a72', text: '56', isCorrect: true, isSelected: true),
            QuizAnswer(id: 'a73', text: '64', isCorrect: false),
          ],
        ),
      ],
    ),
  };

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
