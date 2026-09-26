import '../../features/auth/domain/entities/user.dart';
import '../../features/courses/domain/entities/course.dart';
import '../../features/gallery/domain/entities/gallery_album.dart';
import '../../features/home/domain/entities/news_item.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/achievements/domain/entities/achievement.dart';
import '../../features/quiz/domain/entities/quiz.dart';
import '../../features/subscription/domain/entities/plan.dart';
import '../theme/app_assets.dart';

abstract final class MockCatalog {
  static const user = User(
    id: 'u1',
    name: 'Rashed eybo',
    phone: '0937857596',
    email: 'ahmed@darb.app',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    progress: 0.4,
    points: 55,
    enrolledCoursesCount: 6,
  );

  // المواد الدراسية (مرحلة التعليم العام). مجموع الدورات = 22 (يظهر في بطاقة التقدم).
  static const categories = [
    Category(id: 'science', name: 'العلوم', icon: 'science', coursesCount: 5),
    Category(id: 'math', name: 'الرياضيات', icon: 'math', coursesCount: 6),
    Category(id: 'social', name: 'الاجتماعيات', icon: 'social', coursesCount: 4),
    Category(id: 'arabic', name: 'اللغة العربية', icon: 'arabic', coursesCount: 3),
    Category(id: 'english', name: 'اللغة الإنجليزية', icon: 'english', coursesCount: 2),
    Category(id: 'physics', name: 'الفيزياء', icon: 'physics', coursesCount: 2),
  ];

  static const courses = [
    Course(
      id: 'c1',
      title: 'دورة الرياضيات',
      instructor: 'أ. عمر النابلسي',
      imageUrl: 'https://picsum.photos/seed/math/800/500',
      categoryId: 'math',
      categoryName: 'الرياضيات',
      lessonsCount: 12,
      chaptersCount: 9,
      studentsCount: 22,
      rating: 4.8,
      price: 120,
      progress: 0.4,
      description:
          'دورة شاملة في الرياضيات تغطي الجبر والهندسة والتحليل بأسلوب مبسّط يناسب طلاب المرحلة الثانوية.',
      lessons: [
        Lesson(id: 'l1', title: 'مقدمة في الجبر', duration: '12:40', isLocked: false, isCompleted: true),
        Lesson(id: 'l2', title: 'المعادلات من الدرجة الأولى', duration: '18:20', isLocked: false),
        Lesson(id: 'l3', title: 'الهندسة التحليلية', duration: '22:05', isLocked: true),
        Lesson(id: 'l4', title: 'المشتقات والتكامل', duration: '16:10', isLocked: true),
      ],
    ),
    Course(
      id: 'c2',
      title: 'دورة العلوم',
      instructor: 'أ. سارة الحلبي',
      imageUrl: 'https://picsum.photos/seed/science/800/500',
      categoryId: 'science',
      categoryName: 'العلوم',
      lessonsCount: 15,
      chaptersCount: 7,
      studentsCount: 34,
      rating: 4.7,
      price: 110,
      progress: 0.15,
      description: 'رحلة في عالم العلوم تشمل الأحياء والكيمياء وتجارب عملية تبسّط المفاهيم.',
      lessons: [
        Lesson(id: 'l1', title: 'الخلية ووظائفها', duration: '14:00', isLocked: false),
        Lesson(id: 'l2', title: 'العناصر والمركبات', duration: '11:30', isLocked: false),
      ],
    ),
    Course(
      id: 'c3',
      title: 'دورة الاجتماعيات',
      instructor: 'أ. ليلى حمصي',
      imageUrl: 'https://picsum.photos/seed/social/800/500',
      categoryId: 'social',
      categoryName: 'الاجتماعيات',
      lessonsCount: 10,
      chaptersCount: 6,
      studentsCount: 28,
      rating: 4.6,
      price: 90,
      progress: 0.7,
      description: 'مادة الاجتماعيات بين التاريخ والجغرافيا لفهم محيطنا وماضينا.',
      lessons: [
        Lesson(id: 'l1', title: 'خرائط ومواقع', duration: '10:15', isLocked: false, isCompleted: true),
        Lesson(id: 'l2', title: 'الحضارات القديمة', duration: '13:40', isLocked: false),
      ],
    ),
    Course(
      id: 'c4',
      title: 'دورة اللغة العربية',
      instructor: 'أ. محمود الدمشقي',
      imageUrl: 'https://picsum.photos/seed/arabic/800/500',
      categoryId: 'arabic',
      categoryName: 'اللغة العربية',
      lessonsCount: 14,
      chaptersCount: 8,
      studentsCount: 41,
      rating: 4.9,
      price: 100,
      progress: 0.25,
      description: 'قواعد النحو والصرف والبلاغة مع تطبيقات على النصوص الأدبية.',
      lessons: [
        Lesson(id: 'l1', title: 'أقسام الكلام', duration: '15:00', isLocked: false),
        Lesson(id: 'l2', title: 'الإعراب والبناء', duration: '19:20', isLocked: true),
      ],
    ),
    Course(
      id: 'c5',
      title: 'دورة اللغة الإنجليزية',
      instructor: 'أ. رنا الشامي',
      imageUrl: 'https://picsum.photos/seed/english/800/500',
      categoryId: 'english',
      categoryName: 'اللغة الإنجليزية',
      lessonsCount: 11,
      chaptersCount: 5,
      studentsCount: 37,
      rating: 4.7,
      price: 130,
      progress: 0.5,
      description: 'مسار متدرج لبناء المفردات والقواعد والمحادثة اليومية.',
      lessons: [
        Lesson(id: 'l1', title: 'Alphabet & Sounds', duration: '10:15', isLocked: false, isCompleted: true),
        Lesson(id: 'l2', title: 'Basic Sentences', duration: '13:40', isLocked: false),
      ],
    ),
    Course(
      id: 'c6',
      title: 'دورة الفيزياء',
      instructor: 'أ. خالد حماة',
      imageUrl: 'https://picsum.photos/seed/physics/800/500',
      categoryId: 'physics',
      categoryName: 'الفيزياء',
      lessonsCount: 13,
      chaptersCount: 6,
      studentsCount: 19,
      rating: 4.5,
      price: 125,
      progress: 0,
      description: 'من الحركة إلى الكهرباء: مبادئ الفيزياء بتجارب وأمثلة من الحياة.',
      lessons: [
        Lesson(id: 'l1', title: 'الحركة والسرعة', duration: '15:00', isLocked: false),
        Lesson(id: 'l2', title: 'قوانين نيوتن', duration: '19:20', isLocked: true),
      ],
    ),
  ];

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

  // أسئلة رياضيات مشتركة تُستخدم في اختبارات ونشاطات شاشة «إختباراتي».
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

  // بطاقات شاشة «إختباراتي»: تبويب «إختبارات» (kind=test) و«نشاطات يومية»
  // (kind=activity). كلاهما يفتح تدفق حل الأسئلة نفسه عند الضغط.
  static const quizzes = [
    // ── إختبارات ──
    Quiz(id: 'qt1', title: 'إختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.عمر النابلسي', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    Quiz(id: 'qt2', title: 'إختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    Quiz(id: 'qt3', title: 'إختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.أحمد الحفار', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    Quiz(id: 'qt4', title: 'إختبار رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions),
    // ── نشاطات يومية ──
    Quiz(id: 'qa1', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.عمر النابلسي', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
    Quiz(id: 'qa2', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
    Quiz(id: 'qa3', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.أحمد الحفار', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
    Quiz(id: 'qa4', title: 'نشاطات رياضيات', courseTitle: 'الرياضيات', instructor: 'أ.باسم السليمان', questionsCount: 20, durationMinutes: 20, participants: 22, progress: 0, questions: _mathQuestions, kind: QuizKind.activity),
  ];

  static const plans = [
    Plan(
      id: 'monthly',
      name: 'شهري',
      price: 49,
      period: 'شهرياً',
      features: ['كل الدورات', 'الاختبارات', 'شهادات إتمام'],
    ),
    Plan(
      id: 'yearly',
      name: 'سنوي',
      price: 399,
      period: 'سنوياً',
      features: ['كل الدورات', 'الاختبارات', 'شهادات إتمام', 'دعم أولوية'],
      highlighted: true,
    ),
  ];

  static const notifications = [
    AppNotification(
      id: 'n1',
      title: 'درس جديد',
      body: 'تم إضافة درس مصادر الالتزام إلى دورة القانون المدني.',
      time: 'منذ ساعتين',
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      title: 'تذكير بالاختبار',
      body: 'اختبار الوحدة الأولى ينتهي خلال 24 ساعة.',
      time: 'أمس',
      isRead: true,
    ),
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
