import 'package:flutter/material.dart';

/// A modal route that replaces the entire screen with a platform-adaptive
/// transition.
///
/// {@macro flutter.material.materialRouteTransitionMixin}
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
/// The `fullscreenDialog` property specifies whether the incoming route is a
/// fullscreen modal dialog. On iOS, those routes animate from the bottom to the
/// top rather than horizontally.
///
/// If `barrierDismissible` is true, then pressing the escape key on the keyboard
/// will cause the current route to be popped with null as the value.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] by providing the
/// optional `result` argument.
///
/// See also:
///
///  * [StaticRouteTransitionMixin], which provides the material transition
///    for this route.
///  * [MaterialPage], which is a [Page] of this class.
class StaticPageRoute<T> extends PageRoute<T> with StaticRouteTransitionMixin<T> {
  /// Construct a MaterialPageRoute whose contents are defined by [builder].
  StaticPageRoute({
    required this.builder,
    super.settings,
    super.requestFocus,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
  }) {
    assert(opaque);
  }

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}


/// A mixin that provides platform-adaptive transitions for a [PageRoute].
///
/// {@template flutter.material.materialRouteTransitionMixin}
/// For Android, the entrance transition for the page zooms in and fades in
/// while the exiting page zooms out and fades out. The exit transition is similar,
/// but in reverse.
///
/// For iOS, the page slides in from the right and exits in reverse. The page
/// also shifts to the left in parallax when another page enters to cover it.
/// (These directions are flipped in environments with a right-to-left reading
/// direction.)
/// {@endtemplate}
///
/// See also:
///
///  * [PageTransitionsTheme], which defines the default page transitions used
///    by the [StaticRouteTransitionMixin.buildTransitions].
///  * [ZoomPageTransitionsBuilder], which is the default page transition used
///    by the [PageTransitionsTheme].
///  * [CupertinoPageTransitionsBuilder], which is the default page transition
///    for iOS and macOS.
mixin StaticRouteTransitionMixin<T> on PageRoute<T> {
  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(BuildContext context);

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => false;

  @override
  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      ) {
    final Widget result = buildContent(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}