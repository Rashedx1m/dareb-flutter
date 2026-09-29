import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// محوّل Dio مزيّف: يعيد رداً محدداً لكل مسار ويسجّل الطلبات المرسلة،
/// لاختبار مصادر البيانات دون اتصال بالخادم.
class FakeHttpAdapter implements HttpClientAdapter {
  final Map<String, (int, Object)> _responses = {};
  final List<RequestOptions> requests = [];

  void on(String path, {int status = 200, required Object body}) {
    _responses[path] = (status, body);
  }

  @override
  Future<ResponseBody> fetch(
      RequestOptions options,
      Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture,
      ) async {
    requests.add(options);
    final (status, body) = _responses[options.path] ?? (404, {'message': 'not stubbed'});
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// حقول الـ form-data المرسلة في الطلب.
Map<String, String> formFields(RequestOptions request) =>
    Map.fromEntries((request.data as FormData).fields);