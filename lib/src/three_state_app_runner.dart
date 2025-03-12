import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_things/src/view_things.dart';

/// Wrapper for [runApp] and [runWidget].
///
/// Provides a simple way to create splash and exit views.
///
/// Splash is only for desktop and web.
/// Android and iOS provides their own splash screens.
class ThreeStateAppRunner {
  ThreeStateAppRunner({
    required this.builder,
    required this.transitionDuration,
    required this.transitionCurve,
    required this.transitionBuilder,
    this.onChange,
  });

  final void Function(ThreeState? from, ThreeState to)? onChange;
  final Widget Function(BuildContext context, ThreeState target) builder;
  final Duration transitionDuration;
  final Curve transitionCurve;

  final Widget Function(
    Widget? fromWidget,
    Widget toWidget,
    ThreeState from,
    ThreeState to,
    Animation<double>,
  )
  transitionBuilder;

  ValueNotifier<ThreeState>? _stateNotifier;

  void go(ThreeState state) {
    assert(_stateNotifier != null, 'Before using .go() call .run()');
    if (kDebugMode) {
      debugPrint('Going to $state');
    }
    onChange?.call(_stateNotifier!.value, state);
    _stateNotifier!.value = state;
  }

  /// This method must be called only once.
  void run(ThreeState initial) {
    assert(_stateNotifier == null, '.run() must be called only once.');
    _stateNotifier = ValueNotifier(initial);
    final binding = WidgetsFlutterBinding.ensureInitialized();

    onChange?.call(null, initial);

    runWidget(
      ThreeStateView(
        stateNotifier: _stateNotifier!,
        view: binding.platformDispatcher.implicitView!,
        builder: builder,
        transitionBuilder: transitionBuilder,
        transitionCurve: transitionCurve,
        transitionDuration: transitionDuration,
      ),
    );
  }
}

enum ThreeState { splash, main, exit }
