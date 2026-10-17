import '../../domain/entities/news_item.dart';

/// خبر كما يعيده `home-page/index` و`news/all`: `{id, link, image}` بلا عنوان.
class NewsItemModel extends NewsItem {
  const NewsItemModel({
    required super.id,
    required super.imageUrl,
    required super.link,
  });

  factory NewsItemModel.fromJson(Map<String, dynamic> json) {
    return NewsItemModel(
      id: '${json['id']}',
      imageUrl: json['image'] as String,
      link: json['link'] as String,
    );
  }
}
