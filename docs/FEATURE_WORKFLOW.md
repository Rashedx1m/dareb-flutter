# منهج بناء ميزة في تطبيق درب

المرجع الثابت لكل ميزة جديدة، ولكل ميزة تجريبية تُربط بالخادم. كل PR يُراجع على هذا الملف.

## 1. الفكرة

كل ميزة ثلاث طبقات، والاعتماد يتجه إلى الداخل فقط:

```
presentation  ──►  domain  ◄──  data
الصفحة، Cubit      Entity، Repository مجرد، UseCase      Model، DataSource، RepositoryImpl
```

- `domain` قلب الميزة: Dart فقط، لا يعرف Flutter ولا JSON ولا الخادم.
- `data` يعرف الخادم: يحوّل ردوده إلى Entities واستثناءاته إلى `Failure`.
- `presentation` لا يعرف إلا الـ UseCases.

الطلب يمرّ هكذا: الصفحة ← Cubit ← UseCase ← Repository ← DataSource ← `ApiClient`.
والرد يعود هكذا: JSON ← Model ← `Either<Failure, Entity>` ← State ← الواجهة.

## 2. ملفات الميزة

```
lib/features/<feature>/
  domain/
    entities/<thing>.dart
    repositories/<feature>_repository.dart
    usecases/<verb>_<thing>.dart              ملف لكل UseCase
  data/
    models/<thing>_model.dart                 ملف لكل Model
    datasources/<feature>_remote_data_source.dart
    repositories/<feature>_repository_impl.dart
  presentation/
    cubit/<screen>_cubit.dart
    cubit/<screen>_state.dart                 part of الـ Cubit
    pages/<screen>_page.dart
    widgets/<widget>.dart

test/features/<feature>/
  <feature>_data_test.dart                    Model + DataSource + Repository
  <feature>_cubits_test.dart                  Cubits مع مستودع مزيّف
  <feature>_flow_test.dart                    الشاشة كما يستخدمها المستخدم
```

## 3. الأسماء

| العنصر | القاعدة | مثال |
|---|---|---|
| Entity | اسم الشيء | `SubscriptionPackage` |
| Model | الـ Entity + `Model` | `SubscriptionPackageModel` |
| Repository | `<Feature>Repository` و`<Feature>RepositoryImpl` | `SubscriptionRepository` |
| DataSource | `<Feature>RemoteDataSource` و`…Impl`، والتجريبي `…MockDataSource` | `SupportRemoteDataSourceImpl` |
| UseCase | فعل + مفعول، بلا لاحقة `UseCase` | `GetPackages`، `SubscribeWithCode` |
| معامل الـ UseCase | `NoParams`، أو قيمة واحدة، أو Entity، أو `<UseCase>Params` | `VerifyOtpParams` |
| Cubit / State | `<Screen>Cubit` و`<Screen>State` | `CheckoutCubit` |
| حالة الجلب | `<Screen>Status { initial, loading, success, failure }` | `PackagesStatus` |
| حالة فعل يرسل شيئاً | `{ idle, sending, done, failure }` | `ActivationStatus` |
| الفرع | `feat/…`، `fix/…`، `refactor/…` | `feat/notifications-backend` |
| الـ commit | `type(scope): وصف بالإنجليزية` | `feat(subscription): add data layer` |

## 4. الخطوات

بعد كل خطوة من 1 إلى 4: `flutter analyze`، ثم مراجعة الفرق، ثم commit.

### الخطوة 0: الفهم قبل الكود

1. من التصميم اكتب: الشاشات، وما يفعله المستخدم في كل شاشة، والحالات الأربع لكل شاشة: تحميل، فارغ، خطأ، نجاح.
2. لكل endpoint أرسل طلباً حقيقياً (Postman) وسجّل:
   - شكل `data` داخل الغلاف `{message, data}`.
   - الحقول التي قد تأتي `null` أو بنوع مختلف (رقم مكتوب كنص مثلاً).
   - ردود الخطأ: 400 (رسالة عمل)، 422 (أخطاء حقول)، 404، 401.
   - طلب فارغ يكشف قواعد الـ 422 دون أن يُحفظ شيء.
3. احفظ رداً حقيقياً واحداً على الأقل؛ ستضعه كما هو في اختبار البيانات.
4. افتح فرعاً من `main` المحدّث، أو من فرع الـ PR السابق إن لم يُدمج بعد.

### الخطوة 1: Domain

**Entity**: كل الحقول `final`، والمعرّفات `String`، والاختياري nullable أو بقيمة افتراضية، و`props` تضم كل الحقول.

```dart
class AppNotification extends Equatable {
  const AppNotification({required this.id, required this.title, this.body, this.isRead = false});

  final String id;
  final String title;

  /// `null` إن أرسل الخادم إشعاراً بعنوان فقط.
  final String? body;
  final bool isRead;

  @override
  List<Object?> get props => [id, title, body, isRead];
}
```

**Repository مجرد**: كل دالة تُرجع `Future<Either<Failure, T>>`.

```dart
abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
}
```

**UseCase**: ملف لكل فعل.

```dart
class GetNotifications implements UseCase<List<AppNotification>, NoParams> {
  const GetNotifications(this.repository);
  final NotificationsRepository repository;

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) {
    return repository.getNotifications();
  }
}
```

commit: `feat(<feature>): add domain layer`

### الخطوة 2: Data

**Model**: يرث الـ Entity، وقراءة JSON كلها في `fromJson`. أضف `toJson` فقط إن كان سيُخزَّن محلياً (مثل `UserModel`).

```dart
class AppNotificationModel extends AppNotification {
  const AppNotificationModel({required super.id, required super.title, super.body, super.isRead});

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: '${json['id']}',
      title: json['title'] as String,
      body: json['body'] as String?,
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }
}
```

- الحقل الذي رأيته في رد حقيقي يُقرأ بصرامة (`as String`). إن تغيّر شكله، يحوّله `ApiClient` إلى «رد غير متوقع» بدل أن تتجمد الشاشة.
- الحقل الذي لم تره بعد يُقرأ بتسامح مع قيمة افتراضية، وتعليق يقول ذلك (مثل `SubscriptionPackageModel`).

**DataSource**: واجهة مجردة تُرجع Models، وتنفيذ يستدعي `ApiClient`.

```dart
abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<AppNotificationModel>> getNotifications() {
    return _client.get(
      '/notifications/all',
      parse: (data) => [
        for (final json in (data as List).cast<Map<String, dynamic>>()) AppNotificationModel.fromJson(json),
      ],
    );
  }
}
```

- المسار يبدأ بـ `/`.
- `parse:` في كل طلب يُرجع بيانات.
- لا `try/catch`: `ApiClient` يرمي `ServerException` و`ValidationException` و`AuthException` برسائل عربية.
- إن لم يجهز الـ endpoint بعد: `NotificationsMockDataSource implements NotificationsRemoteDataSource` يقرأ من `MockCatalog`، ويُستبدل لاحقاً في DI وحده.

**RepositoryImpl**: ثلاث خطوات ثابتة، ولا `try/catch`.

```dart
@override
Future<Either<Failure, void>> subscribeWithCode(String code) async {
  final trimmed = code.trim();                                                              // 1. تنظيف
  if (trimmed.isEmpty) return const Left(ValidationFailure(AppStrings.errorCodeRequired)); // 2. تحقق
  return guard(() => _remote.subscribeWithCode(trimmed));                                   // 3. استدعاء
}

@override
Future<Either<Failure, List<AppNotification>>> getNotifications() => guard(_remote.getNotifications);
```

قواعد التحقق المشتركة في `core/utils/validators.dart` (`Validators.phone`، `Validators.notEmpty`…).

**اختبار البيانات** `<feature>_data_test.dart`:

```dart
/// رد `notifications/all` كما أعاده الخادم في <التاريخ>.
const _json = {'id': 1, 'title': 'مرحباً', 'body': null, 'is_read': 0};

test('fromJson على الرد الحقيقي', () {
  // Equatable يقارن النوع أيضاً، فالمتوقَّع Model لا Entity.
  expect(AppNotificationModel.fromJson(_json), const AppNotificationModel(id: '1', title: 'مرحباً'));
});

group('المصدر والمستودع', () {
  late FakeHttpAdapter adapter;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    repository = NotificationsRepositoryImpl(
      NotificationsRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
    );
  });

  test('القائمة من notifications/all', () async {
    adapter.on('/notifications/all', body: {'message': 'ok', 'data': [_json]});
    expect((await repository.getNotifications()).getOrElse(() => []), hasLength(1));
  });
});
```

غطِّ: قراءة الرد الحقيقي، والمسار والحقول المرسلة (`adapter.requests` و`formFields`)، وخطأ 422 أو 400 أو 404.

commit: `feat(<feature>): add data layer`

### الخطوة 3: Cubit وState

```dart
// notifications_state.dart
part of 'notifications_cubit.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({this.status = NotificationsStatus.initial, this.items = const [], this.error});

  final NotificationsStatus status;
  final List<AppNotification> items;

  /// يُعرض فقط مع `failure`.
  final String? error;

  NotificationsState copyWith({NotificationsStatus? status, List<AppNotification>? items, String? error}) {
    return NotificationsState(status: status ?? this.status, items: items ?? this.items, error: error);
  }

  @override
  List<Object?> get props => [status, items, error];
}
```

```dart
// notifications_cubit.dart
part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._getNotifications) : super(const NotificationsState());

  final GetNotifications _getNotifications;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    final result = await _getNotifications(const NoParams());
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(status: NotificationsStatus.failure, error: failure.message),
      (items) => state.copyWith(status: NotificationsStatus.success, items: items),
    ));
  }
}
```

- الـ Cubit يستقبل UseCases فقط. أكثر من واحد: `required this._getX`.
- `if (isClosed) return;` بعد كل `await`، لأن الصفحة قد تُغلق قبل وصول الرد.
- الفعل الذي يرسل شيئاً (حفظ، تفعيل) له حقل حالة ورسالة خطأ منفصلان عن حالة الجلب، حتى لا يمسح فشلُه بيانات الشاشة (`activation` في `SubscriptionState`، و`saveStatus` في `ProfileState`).
- الجزء الذي يُفتح وحده (ورقة، نافذة) له Cubit خاص (`PackageSubjectsCubit`، `ContactCubit`).

**اختبار الـ Cubit** `<feature>_cubits_test.dart`: مستودع مزيّف، والـ UseCases حقيقية.

```dart
class _FakeRepository implements NotificationsRepository {
  _FakeRepository([this.result = const Right([])]);
  final Either<Failure, List<AppNotification>> result;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async => result;
}

test('الفشل يصل برسالته', () async {
  final cubit = NotificationsCubit(GetNotifications(_FakeRepository(const Left(ServerFailure('x')))));
  await cubit.load();
  expect(cubit.state, const NotificationsState(status: NotificationsStatus.failure, error: 'x'));
});
```

commit: `feat(<feature>): add cubit`

### الخطوة 4: DI والمسار والواجهة

**DI**: دالة `_init<Feature>()` في `core/di/injection.dart` تُستدعى من `initDependencies`.

```dart
void _initNotifications() {
  sl
    ..registerLazySingleton<NotificationsRemoteDataSource>(() => NotificationsRemoteDataSourceImpl(sl()))
    ..registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetNotifications(sl()))
    ..registerFactory(() => NotificationsCubit(sl()));
}
```

المصدر والمستودع والـ UseCases بلا حالة، فتُشارك نسخة واحدة (`LazySingleton`). الـ Cubit يحمل حالة الشاشة ويُغلق معها، فيلزم نسخة جديدة لكل صفحة (`Factory`).

**المسار** في `core/router/app_router.dart`:

```dart
GoRoute(
  path: '/notifications',
  builder: (_, _) => BlocProvider(
    create: (_) => sl<NotificationsCubit>()..load(),
    child: const NotificationsPage(),
  ),
),
```

المعطيات في `pathParameters` أو `queryParameters` (`/checkout?package=1`)، لا في `extra`، حتى تعمل الصفحة إن فُتحت مباشرة.

**الصفحة**:

```dart
BlocBuilder<NotificationsCubit, NotificationsState>(
  builder: (context, state) => switch (state.status) {
    NotificationsStatus.failure =>
      ErrorView(message: state.error, onRetry: context.read<NotificationsCubit>().load),
    NotificationsStatus.success when state.items.isEmpty => const _EmptyView(),
    NotificationsStatus.success => _NotificationsList(items: state.items),
    _ => const LoadingView(),
  },
)
```

- ما يحدث مرة واحدة (SnackBar، رجوع، انتقال) في `listener` مع `listenWhen`، لا في `builder`.
- النصوص في `AppStrings`، والألوان في `AppColors`، والأيقونات من `app_icons.dart`. لا `Color(0x…)` ولا نص عربي داخل الواجهة.
- ابدأ بعناصر `core/widgets` (`PageHeader`، `ErrorView`، `LoadingView`، `AppButton`)، وعناصر الميزة في `presentation/widgets/`.

**اختبار الواجهة** `<feature>_flow_test.dart` للمسار الأساسي (فتح الشاشة، فعل، نتيجة)، وأضف المسار إلى `test/core/router/routes_smoke_test.dart`.

commit: `feat(<feature>): build screens`

### الخطوة 5: التحقق والتسليم

1. `flutter analyze` ثم `flutter test`.
2. على الخادم الحقيقي (رمز التحقق 1111): جرّب الحالات الأربع، وافصل الإنترنت لترى رسالة الخطأ وزر إعادة المحاولة.
3. `git diff main --stat`، وراجع: لا `print`، ولا `TODO`، ولا كود معلّق، ولا ملفات شخصية.
4. ادفع الفرع، ثم افتح PR من صفحة compare على GitHub.

## 5. قواعد الاعتماد

| الطبقة | تستورد من | لا تستورد من |
|---|---|---|
| `domain` | `domain`، و`core` (error، usecase، utils) | `data`، `presentation`، Flutter |
| `data` | `domain`، `data`، `core` | `presentation` |
| `presentation` | `domain`، `presentation`، `core` | `data` |

بين الميزات:

- مسموح: `domain` ميزة أخرى (`home` يستخدم `GetCourses` من `courses`)، وعناصر الواجهة المعدّة للمشاركة (`showContactSheet`، `LookupSheet`).
- ممنوع: `data` ميزة أخرى.
- ما تحتاجه ميزتان ولا ينتمي إلى إحداهما ينتقل إلى `core/`، كما انتقل `Validators`.
- الميزة التي هي شاشة فوق بيانات ميزة أخرى (`profile` فوق `auth`) لا تحتاج `domain` ولا `data` خاصين بها.
- `sl` لا يُستدعى في الواجهة إلا لإنشاء Cubit. الاستثناء الوحيد: الموجّه وشاشة البداية يقرآن `AuthRepository.cachedUser`، لأن `redirect` متزامن.

## 6. رحلة الخطأ

```
DioException  ──ApiClient──►  ServerException / ValidationException / AuthException
              ──guard──────►  ServerFailure   / ValidationFailure   / AuthFailure
              ──Cubit──────►  state.error (نص عربي)  ──►  ErrorView أو SnackBar
```

- رد 401 على طلب بتوكن: `SessionExpiry` يمسح الجلسة، والموجّه يفتح صفحة الدخول تلقائياً.
- أي `Exception` آخر يصير `ServerFailure('حدث خطأ غير متوقع')`.
- الأخطاء البرمجية (`Error`) لا تُبتلع، لتظهر أثناء التطوير.
- لذلك لا `try/catch` في المستودع ولا في الـ Cubit.

## 7. قائمة الانتهاء

- [ ] الحالات الأربع ظاهرة: تحميل، فارغ، خطأ مع إعادة المحاولة، نجاح
- [ ] ملفات الاختبار الثلاثة ناجحة، و`flutter analyze` نظيف
- [ ] لا نص ولا لون مكتوب مباشرة في الواجهة
- [ ] `_init<Feature>()` في DI، والمسار في `routes_smoke_test`
- [ ] جُرّبت على الخادم الحقيقي
- [ ] لا TODO ولا ملفات شخصية في الفرق
- [ ] ما عُرف عن الـ API (شكل الرد، القواعد) مكتوب في تعليق الـ Model أو في الاختبار
