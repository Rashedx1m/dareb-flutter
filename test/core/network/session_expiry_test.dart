import 'package:educational_app/core/network/session_expiry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expire يمسح الجلسة أولاً ثم يُعلم المستمعين', () async {
    final events = <String>[];
    final expiry = SessionExpiry(() async => events.add('clear'))
      ..addListener(() => events.add('notify'));

    await expiry.expire();

    expect(events, ['clear', 'notify']);
  });
}
