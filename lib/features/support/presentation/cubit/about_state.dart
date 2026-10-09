part of 'about_cubit.dart';

enum AboutStatus { initial, loading, success, failure }

class AboutState extends Equatable {
  const AboutState({this.status = AboutStatus.initial, this.links = const ContactLinks(), this.error});

  final AboutStatus status;

  /// فارغة (كل رابط `null`) إلى أن تصل من الخادم.
  final ContactLinks links;
  final String? error;

  @override
  List<Object?> get props => [status, links, error];
}
