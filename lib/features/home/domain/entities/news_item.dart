import 'package:equatable/equatable.dart';

/// خبر يظهر في قسم «آخر الأخبار» على الصفحة الرئيسية.
class NewsItem extends Equatable {
  const NewsItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String date;

  @override
  List<Object?> get props => [id, title];
}
