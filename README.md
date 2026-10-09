# Dareb — تطبيق «درب» التعليمي (Flutter)

تطبيق تعليمي فيه المواد والدورات والاختبارات والاشتراكات، مبني على **Clean Architecture** لكل ميزة.

الواجهة الخلفية في مستودع منفصل: [dareb-backend](https://github.com/Rashedx1m/dareb-backend).

## المعمارية

كل ميزة في `lib/features/<feature>/` مقسّمة إلى ثلاث طبقات:

| الطبقة | المحتوى |
|---|---|
| `domain/` | الكيانات، والواجهات المجردة للمستودعات، والـ UseCases (ملف لكل واحد) |
| `data/models/` | تحويل JSON إلى الكيانات (`fromJson`)، ملف لكل Model |
| `data/datasources/` | مصدر البيانات: واجهة `*RemoteDataSource` تُرجع Models أو ترمي `Exception` |
| `data/repositories/` | تنفيذ المستودع: يتحقق من المدخلات ثم يستدعي المصدر داخل `guard` فيحوّل الاستثناءات إلى `Failure` |
| `presentation/` | الصفحات، والـ Cubit/Bloc وحالته في ملف `part`. لا تعرف إلا الـ UseCases |

مسار البيانات دائمًا: **الصفحة ← Cubit ← UseCase ← Repository ← DataSource**.
الصفحات لا تستدعي المستودعات ولا `MockCatalog` مباشرة، والـ Cubit يُحقن في الصفحة من الموجّه.

**خطوات بناء أي ميزة وقواعدها في [docs/FEATURE_WORKFLOW.md](docs/FEATURE_WORKFLOW.md).**

وفي `lib/core/` الأجزاء المشتركة:
- `di/injection.dart`: حقن الاعتماديات بـ get_it، مقسّمة دالةً لكل ميزة.
- `error/`: أنواع `Failure` و`Exception`، و`guard` الذي يحوّل بينهما.
- `network/`: `ApiClient` (الترويسات والتوكن وفك غلاف الرد وتحويل الأخطاء)، و`SessionExpiry` لانتهاء الجلسة.
- `utils/validators.dart`: قواعد التحقق من الحقول المشتركة بين الميزات.
- `router/`: التوجيه بـ go_router، مع حارس يمنع الصفحات الداخلية بلا جلسة.
- `theme/`: الألوان والخطوط والأيقونات.
- `widgets/`: عناصر مشتركة، منها `LoadingView` و`ErrorView` لحالات التحميل.

**الحزم الأساسية:** flutter_bloc، get_it، dartz (`Either<Failure, T>`)، go_router، equatable.

## الحالة الحالية

مربوطة بالخادم: المصادقة والتسجيل (`auth`)، والملف الشخصي (`profile`)، والدعم (`support`)، والاشتراكات (`subscription`).

ما زالت تجريبية من `lib/core/data/mock_catalog.dart` عبر مصادر `*MockDataSource`: الدورات، والاختبارات،
وأخبار الرئيسية، والمعرض، والإشعارات، والإنجازات، والتنزيلات. ربط أي منها: إضافة تنفيذ `*RemoteDataSource`
يستدعي الـ API (مع الـ Models)، ثم تبديل تسجيله في `injection.dart`، دون تعديل المستودع أو الـ UseCases أو الـ Cubits.

## التشغيل

```bash
flutter pub get
flutter run
```

## الاختبارات

```bash
flutter test
```
