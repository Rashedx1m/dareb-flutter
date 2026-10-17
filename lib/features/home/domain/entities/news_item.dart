import 'package:equatable/equatable.dart';

/// خبر في شريط «آخر الأخبار». الخادم يرسل صورة ورابطاً فقط، بلا عنوان ولا تاريخ.
class NewsItem extends Equatable {
  const NewsItem({
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
