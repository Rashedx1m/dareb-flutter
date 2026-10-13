import 'package:equatable/equatable.dart';

import 'subject.dart';
import 'subject_details.dart';

/// نتائج البحث مجمّعة كما في التصميم: النشاطات، ثم الدورات (المواد)، ثم الاختبارات.
class SearchResults extends Equatable {
  const SearchResults({this.subjects = const [], this.exams = const [], this.activities = const []});

  static const empty = SearchResults();

  final List<Subject> subjects;
  final List<SubjectExam> exams;
  final List<SubjectExam> activities;

  bool get isEmpty => subjects.isEmpty && exams.isEmpty && activities.isEmpty;

  @override
  List<Object?> get props => [subjects, exams, activities];
}
