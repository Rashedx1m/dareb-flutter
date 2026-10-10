import 'package:equatable/equatable.dart';

/// مادة دراسية من `subjects/all`، وتفتح منها صفحة دورتها.
class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isFree,
    required this.isSubscribed,
  });

  final String id;
  final String name;
  final String imageUrl;
  final bool isFree;
  final bool isSubscribed;

  @override
  List<Object?> get props => [id, name, imageUrl, isFree, isSubscribed];
}
