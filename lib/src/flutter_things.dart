import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
///   padding: EdgeInsets.only(left: value)
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
