# Dareb — تطبيق «درب» التعليمي (Flutter)

تطبيق تعليمي فيه المواد والدورات والاختبارات والاشتراكات، مبني على **Clean Architecture** لكل ميزة.

الواجهة الخلفية في مستودع منفصل: [dareb-backend](https://github.com/Rashedx1m/dareb-backend).

## المعمارية

كل ميزة في `lib/features/<feature>/` مقسّمة إلى ثلاث طبقات:

| الطبقة | المحتوى |
|---|---|
| `domain/` | الكيانات، والواجهات المجردة للمستودعات، والـ UseCases |
| `data/` | تنفيذ المستودعات. حاليًا يقرأ من `MockCatalog`، وسيُستبدل بطلبات API |
| `presentation/` | الصفحات، والـ Cubit/Bloc |

وفي `lib/core/` الأجزاء المشتركة:
- `di/injection.dart`: حقن الاعتماديات بـ get_it.
- `error/`: أنواع `Failure` و`Exception`.
- `router/`: التوجيه بـ go_router.
- `theme/`: الألوان والخطوط والأيقونات.

**الحزم الأساسية:** flutter_bloc، get_it، dartz (`Either<Failure, T>`)، go_router، equatable.

## الحالة الحالية

البيانات كلها من `lib/core/data/mock_catalog.dart`. الربط مع الـ Backend سيكون باستبدال تنفيذ المستودعات في `data/` فقط، دون تعديل الـ UseCases أو الـ Cubits.

## التشغيل

```bash
flutter pub get
flutter run
```

## الاختبارات

```bash
flutter test
```
