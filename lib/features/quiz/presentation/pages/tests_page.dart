import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/quiz.dart';
import '../bloc/quiz_bloc.dart';

/// شاشة «اختباراتي»: ترويسة فيروزية بحقل بحث، تبويبان (اختبارات / نشاطات يومية)،
/// وقائمة بطاقات. الضغط على بطاقة يفتح تدفّق حلّ الأسئلة.
class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  QuizKind _tab = QuizKind.test;
  String _query = '';

  /// التبويب والبحث حالة عرض محلية تُطبَّق على القائمة المحمّلة في [QuizBloc].
  List<Quiz> _filter(List<Quiz> quizzes) {
    final q = _query.trim();
    return quizzes.where((quiz) {
      if (quiz.kind != _tab) return false;
      if (q.isEmpty) return true;
      return quiz.title.contains(q) || quiz.instructor.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _Header(
              query: _query,
              onQueryChanged: (v) => setState(() => _query = v),
              onNotify: () => context.push('/notifications'),
              onBack: () => context.canPop() ? context.pop() : context.go('/home'),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Tabs(
                selected: _tab,
                onSelect: (t) => setState(() => _tab = t),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: BlocBuilder<QuizBloc, QuizState>(
                builder: (context, state) {
                  final items = _filter(state.quizzes);
                  return switch (state.status) {
                    QuizStatus.initial || QuizStatus.loading => const LoadingView(),
                    QuizStatus.failure => ErrorView(
                        message: state.error,
                        onRetry: () => context.read<QuizBloc>().add(const QuizzesStarted()),
                      ),
                    _ when items.isEmpty => const Center(
                        child: Text(
                          AppStrings.noTestsFound,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ),
                    _ => ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, i) => _QuizCard(
                          quiz: items[i],
                          onTap: () => context.push('/quiz/${items[i].id}'),
                        ),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.query,
    required this.onQueryChanged,
    required this.onNotify,
    required this.onBack,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onNotify;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.headerTeal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [BoxShadow(color: AppColors.shadowStrong, blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderIconButton(
                tooltip: AppStrings.notifications,
                onTap: onNotify,
                child: const Icon(PhosphorIconsRegular.bell, color: Colors.white, size: 22),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    AppStrings.myTests,
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              _HeaderIconButton(
                tooltip: AppStrings.back,
                onTap: onBack,
                child: const Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: onQueryChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: AppStrings.searchHere,
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.iconBlue, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.child, required this.onTap, required this.tooltip});

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 42, height: 42, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onSelect});

  final QuizKind selected;
  final ValueChanged<QuizKind> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.tabTrack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: AppStrings.tabTests,
              selected: selected == QuizKind.test,
              onTap: () => onSelect(QuizKind.test),
            ),
          ),
          Expanded(
            child: _Segment(
              label: AppStrings.tabDailyActivities,
              selected: selected == QuizKind.activity,
              onTap: () => onSelect(QuizKind.activity),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.tabLabel,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz, required this.onTap});

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = quiz.kind == QuizKind.activity ? AppAssets.icActivity : AppAssets.icQuiz;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.quizCardBorder, width: 1.3),
          boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            SizedBox(width: 56, height: 56, child: SvgPicture.asset(icon, fit: BoxFit.contain)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quiz.instructor,
                    style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${quiz.questionsCount} ${AppStrings.questionUnit}',
                    style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
