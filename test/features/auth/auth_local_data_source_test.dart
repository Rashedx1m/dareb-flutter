import 'package:educational_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:educational_app/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPrefsAuthLocalDataSource> _local([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPrefsAuthLocalDataSource(await SharedPreferences.getInstance());
}

final _user = UserModel(id: '30', phone: '0930000000', firstName: 'Rashed', lastName: 'Eybo');

void main() {
  test('يحفظ التوكن والمستخدم ويقرأهما', () async {
    final local = await _local();

    await local.saveToken('30|abc');
    await local.saveUser(_user);

    expect(local.token, '30|abc');
    expect(local.cachedUser, _user);
  });

  test('clear يمسح الجلسة ويُبقي معرّف الجهاز', () async {
    final local = await _local();
    final deviceId = local.deviceId;
    await local.saveToken('30|abc');
    await local.saveUser(_user);

    await local.clear();

    expect(local.token, isNull);
    expect(local.cachedUser, isNull);
    expect(local.deviceId, deviceId);
  });

  test('معرّف الجهاز ثابت بين الاستدعاءات ويبقى بعد إعادة الفتح', () async {
    final local = await _local();
    final first = local.deviceId;

    expect(first, hasLength(32));
    expect(local.deviceId, first);

    final reopened = SharedPrefsAuthLocalDataSource(await SharedPreferences.getInstance());
    expect(reopened.deviceId, first);
  });

  test('مستخدم محفوظ بصيغة تالفة يُعامل كجلسة غير موجودة', () async {
    final local = await _local({'auth.user': '{not json'});

    expect(local.cachedUser, isNull);
  });
}