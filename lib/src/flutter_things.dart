import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide runApp;
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


class TransformAnimation<T, C> implements Animation<T> {
  const TransformAnimation(this._base, {
    required this.transform,
  });

  final Animation<C> _base;
  final T Function(C) transform;

  @override
  void addListener(VoidCallback listener) => _base.addListener(listener);

  @override
  void addStatusListener(AnimationStatusListener listener) => _base.addStatusListener(listener);

  @override
  Animation<U> drive<U>(Animatable<U> child) => _base.drive(child);

  @override
  bool get isAnimating => _base.isAnimating;

  @override
  bool get isCompleted => _base.isCompleted;

  @override
  bool get isDismissed => _base.isDismissed;

  @override
  bool get isForwardOrCompleted => _base.isForwardOrCompleted;

  @override
  void removeListener(VoidCallback listener) {
    _base.removeListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    _base.removeStatusListener(listener);
  }

  @override
  AnimationStatus get status => _base.status;

  @override
  String toStringDetails() => _base.toStringDetails();

  @override
  T get value => transform(_base.value);
}

void clearApp() => runApp(const SizedBox.shrink());

class _RanAppListener {
  const _RanAppListener(this.onStop);

  final Future<void> Function() onStop;
}

WeakReference<_RanAppListener>? _ranAppListener;

Future<void> runApp(Widget app, [Future<void> Function()? onInflateOther]) async {
  await _ranAppListener?.target?.onStop();
  _ranAppListener = null;
  if (onInflateOther != null) {
    _ranAppListener = WeakReference(_RanAppListener(onInflateOther));
  }
  widgets.runApp(app);
}

@immutable
class SaveData {
  const SaveData({
    required this.saved,
  });

  final bool saved;

  SaveData copyWith({ bool? saved }) => SaveData(saved: saved ?? this.saved);
}

class SaveController extends ValueNotifier<SaveData> {
  SaveController() : super(const SaveData(saved: false));

  bool get saved => value.saved;

  void hasChanges() {
    value = value.copyWith(saved: false);
  }

  void save() {
    value = value.copyWith(saved: true);
  }
}