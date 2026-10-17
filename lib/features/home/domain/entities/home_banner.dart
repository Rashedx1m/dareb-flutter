import 'package:equatable/equatable.dart';

/// شريحة سلايدر كما يعيدها الخادم: `{id, link, image}` بلا عنوان.
class HomeBanner extends Equatable {
  const HomeBanner({
    required this.id,
    required this.imageUrl,
    required this.link,
  });

  final String id;
  final String imageUrl;
  final String link;

  @override
  List<Object?> get props => [id, imageUrl, link];
}
