import 'package:equatable/equatable.dart';

/// سطر في «سجل نقاطي»: كم نقطة كسب الطالب، ولماذا، ومتى.
class PointRecord extends Equatable {
  const PointRecord({
    required this.id,
    required this.points,
    this.reason,
    this.date,
  });

  final String id;
  final int points;

  /// `null` إن لم يرسل الخادم سبباً، فتعرض الصفحة مكانه نصاً عاماً.
  final String? reason;

  /// `null` إن لم يرسل الخادم تاريخاً، فتخفي الصفحة سطره.
  final DateTime? date;

  @override
  List<Object?> get props => [id, points, reason, date];
}
