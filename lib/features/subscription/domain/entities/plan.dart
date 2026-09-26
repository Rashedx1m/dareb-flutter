import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.highlighted = false,
  });

  final String id;
  final String name;
  final double price;
  final String period;
  final List<String> features;
  final bool highlighted;

  @override
  List<Object?> get props => [id, name, price];
}
