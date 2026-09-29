# Dareb — تطبيق «درب» التعليمي (Flutter)

تطبيق تعليمي فيه المواد والدورات والاختبارات والاشتراكات، مبني على **Clean Architecture** لكل ميزة.

الواجهة الخلفية في مستودع منفصل: [dareb-backend](https://github.com/Rashedx1m/dareb-backend).

## المعمارية

كل ميزة في `lib/features/<feature>/` مقسّمة إلى ثلاث طبقات:

| الطبقة | المحتوى |
|---|---|
| `domain/` | الكيانات، والواجهات المجردة للمستودعات، والـ UseCases |
| `data/datasources/` | مصدر البيانات: واجهة `*RemoteDataSource` تُرجع البيانات أو ترمي `Exception` |
| `data/repositories/` | تنفيذ المستودع: يستدعي المصدر ويحوّل الاستثناءات إلى `Failure` عبر `guard` |
| `presentation/` | الصفحات، والـ Cubit/Bloc. لا تعرف إلا الـ UseCases |

مسار البيانات دائمًا: **الصفحة ← Cubit ← UseCase ← Repository ← DataSource**.
الصفحات لا تستدعي المستودعات ولا `MockCatalog` مباشرة، والـ Cubit يُحقن في الصفحة من الموجّه.

وفي `lib/core/` الأجزاء المشتركة:
- `di/injection.dart`: حقن الاعتماديات بـ get_it، مقسّمة دالةً لكل ميزة.
- `error/`: أنواع `Failure` و`Exception`، و`guard` الذي يحوّل بينهما.
- `router/`: التوجيه بـ go_router، مع حارس يمنع الصفحات الداخلية بلا جلسة.
- `theme/`: الألوان والخطوط والأيقونات.
- `widgets/`: عناصر مشتركة، منها `LoadingView` و`ErrorView` لحالات التحميل.

**الحزم الأساسية:** flutter_bloc، get_it، dartz (`Either<Failure, T>`)، go_router، equatable.

## الحالة الحالية

البيانات من `lib/core/data/mock_catalog.dart` عبر مصادر `*MockDataSource`، وهي وحدها التي تستورده.
الربط مع الـ Backend لكل ميزة: إضافة تنفيذ `*RemoteDataSource` يستدعي الـ API (مع الـ Models)،
ثم تبديل تسجيله في `injection.dart`، دون تعديل المستودع أو الـ UseCases أو الـ Cubits.
المصادقة (`auth`) ما زالت تحاكي الخادم داخل المستودع وستُعاد هيكلتها عند ربطها.

## التشغيل

```bash
flutter pub get
flutter run
```

## الاختبارات

```bash
flutter test
```
