import 'package:flutter/widgets.dart';

class Restartable extends StatefulWidget {
  final Widget child;

  const Restartable({super.key, required this.child});

  @override
  State<Restartable> createState() => RestartableState();

  static RestartableState? of(BuildContext context) {
    return context.findAncestorStateOfType<RestartableState>();
  }
}

class RestartableState extends State<Restartable> {
  var _key = UniqueKey();

  restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
