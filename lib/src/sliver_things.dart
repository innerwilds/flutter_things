import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart'
    show
        RenderObjectWithChildMixin,
        RenderSliver,
        SliverConstraints,
        SliverGeometry,
        SliverHitTestResult,
        SliverPhysicalParentData,
        applyGrowthDirectionToAxisDirection,
        debugPaintPadding,
        debugPaintSizeEnabled;
import 'package:flutter/widgets.dart';

/// A sliver that applies gap between slivers.
///
/// Slivers are special-purpose widgets that can be combined using a
/// [CustomScrollView] to create custom scroll effects. A [SliverGap]
/// is a sliver that makes a gap between slivers.
class SliverGap extends SingleChildRenderObjectWidget {
  /// Creates a sliver that applies a [gap] between slivers.
  const SliverGap(this.gap, {super.key, Widget? sliver}) : super(child: sliver);

  /// The amount of space between slivers.
  final double gap;

  @override
  RenderSliverGap createRenderObject(BuildContext context) {
    return RenderSliverGap(gap: gap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverGap renderObject) {
    renderObject.gap = gap;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('gap', gap));
  }
}

/// Insets a [RenderSliver], applying padding on each side.
///
/// A [RenderSliverGap] object wraps the [SliverGeometry.layoutExtent] of
/// its child. Any incoming [SliverConstraints.overlap] is ignored and not
/// passed on to the child.
///
/// {@macro flutter.rendering.RenderSliverEdgeInsetsPadding}
class RenderSliverGap extends RenderSliverGapBase {
  /// Creates a render object that makes a gap between its child in a viewport.
  ///
  /// The [gap] argument must be non-negative.
  RenderSliverGap({required double gap, RenderSliver? child})
    : assert(!gap.isNegative),
      _gap = gap {
    this.child = child;
  }

  /// The amount to gap between something.
  @override
  double get gap => _gap;
  double _gap;
  set gap(double value) {
    assert(!gap.isNegative);
    if (_gap == value) {
      return;
    }
    _gap = value;
    markNeedsLayout();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('gap', gap));
  }
}

abstract class RenderSliverGapBase extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver> {
  abstract final double gap;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    double paintOffset({required double from, required double to}) =>
        calculatePaintOffset(constraints, from: from, to: to);
    double cacheOffset({required double from, required double to}) =>
        calculateCacheOffset(constraints, from: from, to: to);

    if (child == null) {
      final paintExtent = paintOffset(from: 0, to: gap);
      final cacheExtent = cacheOffset(from: 0, to: gap);
      geometry = SliverGeometry(
        scrollExtent: gap,
        paintExtent: math.min(paintExtent, constraints.remainingPaintExtent),
        maxPaintExtent: gap,
        cacheExtent: cacheExtent,
      );
      return;
    }
    child!.layout(
      constraints,
      parentUsesSize: true,
    );
    final childLayoutGeometry = child!.geometry!;
    if (childLayoutGeometry.scrollOffsetCorrection != null) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: childLayoutGeometry.scrollOffsetCorrection,
      );
      return;
    }
    final scrollExtent = childLayoutGeometry.scrollExtent;
    final afterPaddingCacheExtent = cacheOffset(
      from: scrollExtent,
      to: gap + scrollExtent,
    );
    final afterPaddingPaintExtent = paintOffset(
      from: scrollExtent,
      to: gap + scrollExtent,
    );
    final mainAxisPaddingCacheExtent = afterPaddingCacheExtent;
    final mainAxisPaddingPaintExtent = afterPaddingPaintExtent;
    final double paintExtent = math.min(
      math.max(
            childLayoutGeometry.paintExtent,
            childLayoutGeometry.layoutExtent + afterPaddingPaintExtent,
          ),
      constraints.remainingPaintExtent,
    );
    geometry = SliverGeometry(
      paintOrigin: childLayoutGeometry.paintOrigin,
      scrollExtent: gap + scrollExtent,
      paintExtent: paintExtent,
      layoutExtent: math.min(
        mainAxisPaddingPaintExtent + childLayoutGeometry.layoutExtent,
        paintExtent,
      ),
      cacheExtent: math.min(
        mainAxisPaddingCacheExtent + childLayoutGeometry.cacheExtent,
        constraints.remainingCacheExtent,
      ),
      maxPaintExtent: gap + childLayoutGeometry.maxPaintExtent,
      hitTestExtent: math.max(
        mainAxisPaddingPaintExtent + childLayoutGeometry.paintExtent,
        childLayoutGeometry.hitTestExtent,
      ),
      hasVisualOverflow: childLayoutGeometry.hasVisualOverflow,
    );
    final calculatedOffset = switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      AxisDirection.up => paintOffset(
        from: gap + scrollExtent,
        to: gap + scrollExtent,
      ),
      AxisDirection.left => paintOffset(
        from: gap + scrollExtent,
        to: gap + scrollExtent,
      ),
      AxisDirection.right => paintOffset(from: 0, to: gap),
      AxisDirection.down => paintOffset(from: 0, to: gap),
    };
    (child!.parentData! as SliverPhysicalParentData)
        .paintOffset = switch (constraints.axis) {
      Axis.horizontal => Offset(calculatedOffset, gap),
      Axis.vertical => Offset(gap, calculatedOffset),
    };
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (child != null && child!.geometry!.hitTestExtent > 0.0) {
      final childParentData = child!.parentData! as SliverPhysicalParentData;
      return result.addWithAxisOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
        mainAxisOffset: childMainAxisPosition(child!),
        crossAxisOffset: childCrossAxisPosition(child!),
        paintOffset: childParentData.paintOffset,
        hitTest: child!.hitTest,
      );
    }
    return false;
  }

  @override
  double childMainAxisPosition(RenderSliver child) {
    assert(child == this.child);
    return calculatePaintOffset(constraints, from: 0, to: gap);
  }

  @override
  double childCrossAxisPosition(RenderSliver child) {
    assert(child == this.child);
    return gap;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    return gap;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child == this.child);
    final childParentData = child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child!.geometry!.visible) {
      final childParentData = child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  void debugPaint(PaintingContext context, Offset offset) {
    super.debugPaint(context, offset);
    assert(() {
      if (debugPaintSizeEnabled) {
        final parentSize = getAbsoluteSize();
        final outerRect = offset & parentSize;
        Rect? innerRect;
        if (child != null) {
          final childSize = child!.getAbsoluteSize();
          final childParentData =
              child!.parentData! as SliverPhysicalParentData;
          innerRect = (offset + childParentData.paintOffset) & childSize;
          assert(innerRect.top >= outerRect.top);
          assert(innerRect.left >= outerRect.left);
          assert(innerRect.right <= outerRect.right);
          assert(innerRect.bottom <= outerRect.bottom);
        }
        debugPaintPadding(context.canvas, outerRect, innerRect);
      }
      return true;
    }());
  }
}
