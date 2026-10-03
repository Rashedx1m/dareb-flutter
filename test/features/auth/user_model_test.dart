import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/data/models/auth_session_model.dart';
import 'package:educational_app/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

// من رد auth/active لحساب جديد.
const _newUserJson = {
  'id': 30,
  'f_name': null,
  'l_name': null,
  'email': null,
  'phone': '0930000000',
  'age': 0,
  'gender': {'id': null, 'name': null},
  'points': 0,
  'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  'subject_count': 0,
};

// من رد profile/get بعد إكمال الحساب.
const _completeUserJson = {
  'id': 30,
  'f_name': 'Rashed',
  'l_name': 'Eybo',
  'email': 'test@example.com',
  'phone': '0930000000',
  'school': {'id': 7, 'name': 'مدرسة يامن', 'governorate': 'damascus'},
  'branch': {'id': 1, 'name': 'الآنسة سالي الضمور'},
  'age': 37,
  'gender': {'id': 1, 'name': 'Male'},
  'points': 12,
  'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  'subject_count': 3,
  'semester_count': 2,
  'medals': 5,
};

void main() {
  test('حساب جديد: الاسم فارغ والحساب غير مكتمل', () {
    final user = UserModel.fromJson(_newUserJson);

    expect(user.id, '30');
    expect(user.name, '');
    expect(user.isProfileComplete, isFalse);
    expect(user.avatarUrl, endsWith('avatars/1.png'));
  });

  test('حساب مكتمل: يجمع الاسم ويقرأ النقاط والدورات', () {
    final user = UserModel.fromJson(_completeUserJson);

    expect(user.name, 'Rashed Eybo');
    expect(user.firstName, 'Rashed');
    expect(user.email, 'test@example.com');
    expect(user.points, 12);
    expect(user.enrolledCoursesCount, 3);
    expect(user.semestersCount, 2);
    expect(user.medalsCount, 5);
    expect(user.isProfileComplete, isTrue);
  });

  test('يقرأ المدرسة من profile/get، ورد auth/active بلا مدرسة', () {
    expect(
      UserModel.fromJson(_completeUserJson).school,
      const School(id: '7', name: 'مدرسة يامن', governorateId: 'damascus'),
    );
    expect(UserModel.fromJson(_newUserJson).school, isNull);
  });

  test('toJson ثم fromJson يعيد المستخدم نفسه، بمدرسته', () {
    final user = UserModel.fromJson(_completeUserJson);

    expect(UserModel.fromJson(user.toJson()), user);
  });
  test('اكتمال الحساب جزء من مساواة المستخدم', () {
    const complete = User(id: '30', name: '', phone: '0930000000');
    const incomplete = User(id: '30', name: '', phone: '0930000000', isProfileComplete: false);

    expect(complete, isNot(incomplete));
  });
  test('AuthSessionModel يقرأ التوكن والمستخدم', () {
    final session = AuthSessionModel.fromJson({'token': '30|abc', 'user': _newUserJson});

    expect(session.token, '30|abc');
    expect(session.user.isProfileComplete, isFalse);
  });
}