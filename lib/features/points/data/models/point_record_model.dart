import '../../domain/entities/point_record.dart';

/// سجل نقطة كما نتوقع أن يعيده `profile/points`. حتى 2026-10-31 لم يُرَ رد فيه
/// بيانات (حساب جديد يعيد `data: []`)، فالمفاتيح تخمين والقراءة كلها متسامحة:
/// الحقل الغائب أو المختلف يصير قيمة افتراضية أو `null` بدل «رد غير متوقع».
class PointRecordModel extends PointRecord {
  const PointRecordModel({
    required super.id,
    required super.points,
    super.reason,
    super.date,
  });

  factory PointRecordModel.fromJson(Map<String, dynamic> json) {
    return PointRecordModel(
      id: '${json['id']}',
      points: _number(json['points'] ?? json['point'])?.toInt() ?? 0,
      reason: _text(json['reason'] ?? json['text'] ?? json['title']),
      date: _date(json['created_at']),
    );
  }

  static num? _number(Object? value) => switch (value) {
        num() => value,
        String() => num.tryParse(value),
        _ => null,
      };

  static String? _text(Object? value) => value is String && value.isNotEmpty ? value : null;

  /// ردود هذا الخادم ترسل `created_at` بتوقيت UTC بالشكل "2026-10-04 15:52:33"
  /// بلا علامة المنطقة، فنضيفها؛ وإن جاء بعلامته يُقرأ كما هو.
  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    return (DateTime.tryParse('${value}Z') ?? DateTime.tryParse(value))?.toLocal();
  }
}
