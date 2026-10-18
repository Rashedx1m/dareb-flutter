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
| `presentation/` | الصفحات، والـ Cubit وحالته في ملف `part`. لا تعرف إلا الـ UseCases |

مسار البيانات دائمًا: **الصفحة ← Cubit ← UseCase ← Repository ← DataSource**.
الصفحات لا تستدعي المستودعات مباشرة، والـ Cubit يُحقن في الصفحة من الموجّه.

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

كل الميزات مربوطة بالخادم: المصادقة والتسجيل، والرئيسية، والدورات والدروس والبحث، والاختبارات، والاشتراكات،
والمعرض، والإشعارات، والإنجازات، والملف الشخصي والدعم.

التنزيلات وحدها تجريبية (`DownloadsMockDataSource`)، لأن ميزة حفظ الملفات على الجهاز لم تُبنَ بعد.

تصاميم فيجما محفوظة في [docs/design/](docs/design/README.md) مع فهرس يربط كل إطار بمساره في التطبيق.

## التشغيل

```bash
flutter pub get
flutter run
```

## الاختبارات

```bash
flutter test
```
