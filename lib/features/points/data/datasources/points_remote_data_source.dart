import '../models/point_record_model.dart';

/// سجل النقاط من الخادم (`profile/points`). يرمي استثناءات `ApiClient` عند الفشل.
abstract class PointsRemoteDataSource {
  Future<List<PointRecordModel>> getPointsHistory();
}

/// تنفيذ تجريبي إلى أن يعيد الخادم سجلاً فيه بيانات، ويُستبدل في DI وحده.
/// فيه سجل بلا سبب وآخر بلا تاريخ، لتظهر الحالتان في الصفحة.
class PointsMockDataSource implements PointsRemoteDataSource {
  const PointsMockDataSource();

  /// زمن طلب محاكى حتى يظهر التحميل.
  static const _latency = Duration(milliseconds: 250);

  @override
  Future<List<PointRecordModel>> getPointsHistory() async {
    await Future<void>.delayed(_latency);
    return [
      PointRecordModel(id: 'p1', points: 10, reason: 'إنهاء اختبار الرياضيات', date: DateTime(2026, 10, 30)),
      PointRecordModel(id: 'p2', points: 5, date: DateTime(2026, 10, 29)),
      const PointRecordModel(id: 'p3', points: 5, reason: 'مشاهدة درس'),
    ];
  }
}
