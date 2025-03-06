import 'dart:async';

import 'package:flutter/widgets.dart';

/// You probably don't need it...
///
/// but it does next: periodically updates state, so builder is called after
/// [duration] forever, while you don't stop the timer.
class TimerBuilder extends StatefulWidget {
  /// Main ctor.
  const TimerBuilder.periodic({
    super.key,
    required this.duration,
    required this.builder,
  });
  
  final Duration duration;
  final Widget Function(BuildContext, Timer) builder;

  @override
  State<TimerBuilder> createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  late Timer timer;
  
  void _handleTimer(Timer timer) {
    setState(() {
      this.timer = timer;
    });
  }
  
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(widget.duration, _handleTimer);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => widget.builder(context, timer);
}
