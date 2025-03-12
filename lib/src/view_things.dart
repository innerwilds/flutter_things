import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_things/flutter_things.dart';

/// Bootstraps a render tree that is rendered into the provided [FlutterView].
///
/// You need to provide this [ThreeStateView] into [ThreeStateScope],
/// to update the state.
///
/// The content rendered into that view is determined by the provided:
///   1. Splash state - [buildSplash].
///   2. App state - [buildApp].
///   3. Exit state - [buildExit].
///
/// Descendants within the same [LookupBoundary] can look up the view they are
/// rendered into via [View.of] and [View.maybeOf].
///
/// The provided content (builders) is wrapped in a [MediaQuery] constructed
/// from the given [view], a [FocusScope], and a [RawView] widget.
///
/// For most use cases, using [MediaQuery.of], or its associated "...Of" methods
/// are a more appropriate way of obtaining the information that a [FlutterView]
/// exposes. For example, using [MediaQuery.sizeOf] will expose the _logical_
/// device size ([MediaQueryData.size]) rather than the physical size
/// ([FlutterView.physicalSize]). Similarly, while [FlutterView.padding] conveys
/// the information from the operating system, the [MediaQueryData.padding]
/// attribute (obtained from [MediaQuery.paddingOf]) further adjusts this
/// information to be aware of the context of the widget; e.g. the [Scaffold]
/// widget adjusts the values for its various children.
///
/// Each [FlutterView] can be associated with at most one [View] or [RawView]
/// widget in the widget tree. Two or more [View] or [RawView] widgets
/// configured with the same [FlutterView] must never exist within the same
/// widget tree at the same time. This limitation is enforced by a
/// [GlobalObjectKey] that derives its identity from the [view] provided to this
/// widget.
///
/// Since the [View] widget bootstraps its own independent render tree using its
/// embedded [RawView], neither it nor any of its descendants will insert a
/// [RenderObject] into an existing render tree. Therefore, the [View] widget
/// can only be used in those parts of the widget tree where it is not required
/// to participate in the construction of the surrounding render tree. In other
/// words, the widget may only be used in a non-rendering zone of the widget
/// tree (see [WidgetsBinding] for a definition of rendering and non-rendering
/// zones).
///
/// In practical terms, the widget is typically used at the root of the widget
/// tree outside of any other [View] or [RawView] widget, as a child of a
/// [ViewCollection] widget, or in the [ViewAnchor.view] slot of a [ViewAnchor]
/// widget. It is not required to be a direct child, though, since other
/// non-[RenderObjectWidget]s (e.g. [InheritedWidget]s, [Builder]s, or
/// [StatefulWidget]s/[StatelessWidget]s that only produce
/// non-[RenderObjectWidget]s) are allowed to be present between those widgets
/// and the [View] widget.
///
/// See also:
///
/// * [RawView], the workhorse that [View] uses to create the render tree, but
///   without the [MediaQuery] and [FocusScope] that [View] adds.
/// * [Element.debugExpectsRenderObjectForSlot], which defines whether a [View]
///   widget is allowed in a given child slot.
class ThreeStateView extends StatelessWidget {
  /// Create a [View] widget to bootstrap a render tree that is rendered into
  /// the provided [FlutterView].
  ///
  /// The content rendered into that [view] is determined by the given [child]
  /// widget.
  const ThreeStateView({
    super.key,
    required this.view,
    required this.builder,
    required this.transitionBuilder,
    required this.transitionCurve,
    required this.transitionDuration,
    required this.stateNotifier,
  });

  /// The [FlutterView] into which a builder child is drawn.
  final FlutterView view;

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

  /// The widget builder which returns widget to insert below this widget in the
  /// tree, which will be drawn into the [view].
  final Widget Function(BuildContext, ThreeState) builder;

  final ValueNotifier<ThreeState> stateNotifier;

  @override
  Widget build(BuildContext context) {
    return View(
      view: view,
      child: _ThreeStateScope(
        stateNotifier: stateNotifier,
        child: _ThreeStateSwitcher(
          transitionDuration: transitionDuration,
          transitionCurve: transitionCurve,
          transitionBuilder: transitionBuilder,
          builder: builder,
        ),
      ),
    );
  }
}

class _ThreeStateSwitcher extends StatefulWidget {
  const _ThreeStateSwitcher({
    required this.builder,
    required this.transitionBuilder,
    required this.transitionCurve,
    required this.transitionDuration,
  });

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

  final Widget Function(BuildContext, ThreeState) builder;

  @override
  State<_ThreeStateSwitcher> createState() => _ThreeStateSwitcherState();
}

class _ThreeStateSwitcherState extends State<_ThreeStateSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  ThreeState? from;
  ThreeState? to;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
    );
    animation = Animation.fromValueListenable(
      CurvedAnimation(parent: controller, curve: widget.transitionCurve),
      transformer: (value) {
        switch (controller.status) {
          case AnimationStatus.completed:
          case AnimationStatus.forward:
            return value;
          case AnimationStatus.dismissed:
          case AnimationStatus.reverse:
            return 1.0 - value;
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = _ThreeStateProvider.of(context);

    /// Initial set.
    if (to == null) {
      from = state;
      to = state;
    } else if (to != state) {
      from = to;
      to = state;
      if (controller.value == 1.0) {
        controller.reverse();
      } else {
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromWidget = switch (from!) {
      _ when animation.value == 1.0 => null,
      _ => widget.builder(context, from!),
    };
    final toWidget = switch (to!) {
      _ => widget.builder(context, to!),
    };

    return widget.transitionBuilder(
      fromWidget,
      toWidget,
      from!,
      to!,
      animation,
    );
  }
}

class _ThreeStateScope extends StatelessWidget {
  const _ThreeStateScope({
    super.key,
    required this.stateNotifier,
    required this.child,
  });

  /// State notifier. Put a state here and [ThreeStateView] makes transition
  /// from current state to a new one.
  final ValueNotifier<ThreeState> stateNotifier;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stateNotifier,
      builder: (_, value, _) {
        return _ThreeStateProvider(state: value, child: child);
      },
    );
  }
}

class _ThreeStateProvider extends InheritedWidget {
  const _ThreeStateProvider({required this.state, required super.child});

  final ThreeState state;

  static ThreeState of(BuildContext context) {
    final _ThreeStateProvider? result =
        context.dependOnInheritedWidgetOfExactType<_ThreeStateProvider>();
    assert(result != null, 'No _ThreeStateProvider found in context');
    return result!.state;
  }

  @override
  bool updateShouldNotify(_ThreeStateProvider old) {
    return state != old.state;
  }
}
