import 'package:flutter/widgets.dart';

/// يستدعي [onReturn] كلما ظهرت الصفحة من جديد بعد أن خُبّئت: عند العودة إلى
/// تبويبها، أو بعد إغلاق صفحة فُتحت فوقها.
///
/// التبويبات تبقى حية في `StatefulShellRoute.indexedStack` فلا تُحمَّل من جديد،
/// وفلاتر يطفئ مؤقتات الجزء المخفي (go_router للتبويب، و`Overlay` للصفحة
/// المغطاة). فعودة المؤقتات تعني عودة الطالب، ربما بعد تفعيل كود أو مشاهدة درس.
class RefreshOnReturn extends StatefulWidget {
  const RefreshOnReturn({super.key, required this.onReturn, required this.child});

  final VoidCallback onReturn;
  final Widget child;

  @override
  State<RefreshOnReturn> createState() => _RefreshOnReturnState();
}

class _RefreshOnReturnState extends State<RefreshOnReturn> {
  /// الصفحة تُبنى أول مرة وهي ظاهرة، وتحميلها الأول عند إنشاء الـ Cubit.
  bool _visible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible) widget.onReturn();
    _visible = visible;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
