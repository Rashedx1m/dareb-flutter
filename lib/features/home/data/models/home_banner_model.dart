import '../../domain/entities/home_banner.dart';

/// شريحة سلايدر كما يعيدها `home-page/index` و`sliders/all`: `{id, link, image}`.
class HomeBannerModel extends HomeBanner {
  const HomeBannerModel({
    required super.id,
    required super.imageUrl,
    required super.link,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: '${json['id']}',
      imageUrl: json['image'] as String,
      link: json['link'] as String,
    );
  }
}
