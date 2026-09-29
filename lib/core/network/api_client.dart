import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import 'api_config.dart';

/// يقرأ توكن الجلسة الحالية، أو `null` إن لم تُفتح جلسة.
typedef TokenReader = String? Function();

/// عميل HTTP الوحيد في التطبيق. يضيف الترويسات والتوكن لكل طلب، ويفكّ غلاف
/// الرد `{message, data}` فيعيد `data` مباشرة، ويحوّل أخطاء الخادم إلى
/// استثناءات طبقة البيانات برسائله العربية.
class ApiClient {
  ApiClient({required TokenReader readToken, Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = readToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => _dio.get<Object?>(path, queryParameters: query));
  }

  /// الخادم يقرأ الحقول كـ form-data، تماماً كما في ملف Postman.
  Future<dynamic> post(String path, {Map<String, dynamic>? fields}) {
    return _send(
          () => _dio.post<Object?>(path, data: fields == null ? null : FormData.fromMap(fields)),
    );
  }

  Future<dynamic> _send(Future<Response<Object?>> Function() request) async {
    try {
      final body = (await request()).data;
      return body is Map ? body['data'] : body;
    } on DioException catch (e) {
      throw _mapError(e);
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