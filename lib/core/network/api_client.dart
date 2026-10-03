import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import 'api_config.dart';

/// يقرأ توكن الجلسة الحالية، أو `null` إن لم تُفتح جلسة.
typedef TokenReader = String? Function();

/// عميل HTTP الوحيد في التطبيق. يضيف الترويسات والتوكن لكل طلب، ويفكّ غلاف
/// الرد `{message, data}` فيعيد `data` مباشرة، ويحوّل أخطاء الخادم إلى
/// استثناءات طبقة البيانات برسائله العربية.
class ApiClient {
  /// [onUnauthorized] يُستدعى حين يرفض الخادم (401) طلباً أُرسل بتوكن، أي أن
  /// الجلسة انتهت أو أُبطلت.
  ApiClient({required TokenReader readToken, this._onUnauthorized, Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,

        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept'] = 'application/json';
          final token = readToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final void Function()? _onUnauthorized;

  static const _unexpectedResponse = ServerException('رد غير متوقع من الخادم');

  /// [parse] يحوّل `data` إلى النوع المطلوب. مرّره لكل رد تقرأه، ليصبح الرد
  /// بشكل غير متوقع [ServerException] بدل خطأ برمجي يعلّق الواجهة.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? parse,
  }) {
    return _send(() => _dio.get<Object?>(path, queryParameters: query), parse);
  }

  /// الخادم يقرأ الحقول كـ form-data، تماماً كما في ملف Postman.
  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? fields,
    T Function(dynamic data)? parse,
  }) {
    return _send(
      () => _dio.post<Object?>(path, data: fields == null ? null : FormData.fromMap(fields)),
      parse,
    );
  }

  /// يرفع ملفاً في الحقل [field] (multipart). البايتات بدل مسار الملف حتى يعمل
  /// على كل المنصات، والويب منها.
  Future<T> upload<T>(
    String path, {
    required String field,
    required List<int> bytes,
    required String fileName,
    required String contentType,
    T Function(dynamic data)? parse,
  }) {
    return _send(
      () => _dio.post<Object?>(
        path,
        data: FormData.fromMap({
          field: MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          ),
        }),
      ),
      parse,
    );
  }

  Future<T> _send<T>(
    Future<Response<Object?>> Function() request,
    T Function(dynamic data)? parse,
  ) async {
    final dynamic data;
    try {
      final body = (await request()).data;
      data = body is Map ? body['data'] : body;
    } on DioException catch (e) {
      // 401 بلا توكن ليس انتهاء جلسة، فلا جلسة أصلاً.
      if (e.response?.statusCode == 401 && e.requestOptions.headers.containsKey('Authorization')) {
        _onUnauthorized?.call();
      }
      throw _mapError(e);
    }
    if (parse == null) return data as T;
    try {
      return parse(data);
    } on TypeError {
      // حقل ناقص أو بنوع مختلف عمّا تتوقعه الـ Models.
      throw _unexpectedResponse;
    } on FormatException {
      throw _unexpectedResponse;
    }
  }

  static Exception _mapError(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ServerException('تعذّر الاتصال بالخادم، تحقق من اتصالك بالإنترنت');
    }
    final body = response.data;
    final message = body is Map ? body['message'] as String? : null;
    return switch (response.statusCode) {
    // رسالة 401 من الخادم إنجليزية ("Unauthenticated.")، فنستبدلها.
      401 => const AuthException('انتهت الجلسة، سجّل الدخول من جديد'),
      422 => ValidationException(_firstError(body) ?? message ?? 'البيانات غير صحيحة'),
      _ => message == null ? const ServerException() : ServerException(message),
    };
  }

  /// أول رسالة في `errors` لرد 422، لأن `message` يلحق بها "(and 6 more errors)".
  static String? _firstError(Object? body) {
    if (body is! Map) return null;
    final errors = body['errors'];
    if (errors is! Map || errors.isEmpty) return null;
    final first = errors.values.first;
    return first is List && first.isNotEmpty ? first.first.toString() : null;
  }
}
