part of '../workout_simple.dart';

const _workoutTransitionDuration = Duration(milliseconds: 220);

Duration _workoutMotionDuration(
  BuildContext context, [
  Duration duration = _workoutTransitionDuration,
]) => MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

/// Animate the current content in place rather than retaining an outgoing copy.
/// This preserves expanded notes, focus and callbacks during rapid set changes.
class _WorkoutChangeTransition extends StatefulWidget {
  const _WorkoutChangeTransition({
    super.key,
    required this.identity,
    required this.child,
    this.reverse = false,
    this.axis = Axis.horizontal,
    this.animateOnMount = false,
    this.duration = _workoutTransitionDuration,
  });

  final Object identity;
  final Widget child;
  final bool reverse;
  final Axis axis;
  final bool animateOnMount;
  final Duration duration;

  @override
  State<_WorkoutChangeTransition> createState() =>
      _WorkoutChangeTransitionState();
}

class _WorkoutChangeTransitionState extends State<_WorkoutChangeTransition>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  bool _reduceMotion = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _controller.value = 1;
    } else if (!_initialized && widget.animateOnMount) {
      _controller.forward(from: 0);
    }
    _initialized = true;
  }

  @override
  void didUpdateWidget(_WorkoutChangeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (oldWidget.identity != widget.identity) {
      if (_reduceMotion) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.reverse ? -1.0 : 1.0;
    final offset = widget.axis == Axis.vertical
        ? Offset(0, .08 * direction)
        : Offset(
            .04 *
                direction *
                (Directionality.of(context) == TextDirection.rtl ? -1 : 1),
            0,
          );
    return FadeTransition(
      opacity: Tween<double>(begin: .35, end: 1).animate(_curve),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedWorkoutProgress extends StatelessWidget {
  const _AnimatedWorkoutProgress({
    super.key,
    required this.value,
    this.color,
    this.minHeight = 3,
  });
  final double value;
  final Color? color;
  final double minHeight;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    duration: _workoutMotionDuration(context),
    curve: Curves.easeOutCubic,
    tween: Tween(begin: value, end: value),
    builder: (context, animatedValue, _) => LinearProgressIndicator(
      value: animatedValue.clamp(0.0, 1.0),
      color: color,
      minHeight: minHeight,
    ),
  );
}

bool _movesToPreviousSet(
  List<WorkoutExercisable> exercises,
  WorkoutSetCursor? current,
  WorkoutSetCursor? previous,
) {
  if (current == null || previous == null) return false;
  final ordered = _orderedSetRefs(exercises);
  final from = ordered.indexWhere(
    (entry) => _sameCursor(entry.cursor, previous),
  );
  final to = ordered.indexWhere((entry) => _sameCursor(entry.cursor, current));
  return from >= 0 && to >= 0 && to < from;
}
