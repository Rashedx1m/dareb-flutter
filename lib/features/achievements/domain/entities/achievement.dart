import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool unlocked;

  @override
  List<Object?> get props => [id, title, unlocked];
}
