import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as widgets show runApp;

/// Represents vertical space.
/// Use instead of Padding(
///   padding: EdgeInsets.only(top: value)
/// )
class VertGap extends SingleChildRenderObjectWidget {
  /// Creates a widget that insets its child.
  const VertGap(
      this.size, {
        super.key,
      });

  /// The amount of space by which to inset the child.
  final double size;

  @override
  RenderPadding createRenderObject(BuildContext context) {
    return RenderPadding(
      padding: EdgeInsets.only(top: size),
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    renderObject
      ..padding = EdgeInsets.only(top: size)
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
  }
}

/// Represents vertical space.
/// Use instead of Padding(
///   padding: EdgeInsets.only(top: value)
/// )
class HorzGap extends SingleChildRenderObjectWidget {
  /// Creates a widget that insets its child.
  const HorzGap(
      this.size, {
        super.key,
      });

  /// The amount of space by which to inset the child.
  final double size;

  @override
  RenderPadding createRenderObject(BuildContext context) {
    return RenderPadding(
      padding: EdgeInsets.only(left: size),
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    renderObject
      ..padding = EdgeInsets.only(left: size)
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
  }
}

/// Represents vertical space on top of child.
/// Use instead of Padding(
///   padding: EdgeInsets.only(top: value),
///   child: ...,
/// )
class TopIndent extends SingleChildRenderObjectWidget {
  /// Creates a widget that insets its child.
  const TopIndent(
      this.size, {
        super.key,
        super.child,
      });

  /// The amount of space by which to inset the child.
  final double size;

  @override
  RenderPadding createRenderObject(BuildContext context) {
    return RenderPadding(
      padding: EdgeInsets.only(top: size),
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    renderObject
      ..padding = EdgeInsets.only(top: size)
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
  }
}

void clearApp() => runApp(const SizedBox.shrink());

// class _RanAppListener {
//   const _RanAppListener(this.onStop);
//
//   final Future<void> Function() onStop;
// }

// WeakReference<_RanAppListener>? _ranAppListener;

// Future<void> runApp(Widget app, [Future<void> Function()? onInflateOther]) async {
//   await _ranAppListener?.target?.onStop();
//   _ranAppListener = null;
//   if (onInflateOther != null) {
//     _ranAppListener = WeakReference(_RanAppListener(onInflateOther));
//   }
//   widgets.runApp(app);
// }
