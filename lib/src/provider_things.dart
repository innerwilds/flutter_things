import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final class Provider<T> extends InheritedWidget {
  const Provider({super.key, required super.child, required this.value});

  final T value;

  @override
  bool updateShouldNotify(covariant Provider<T> oldWidget) {
    return oldWidget.value != value;
  }
}

/// Model provider, based on [ModelProviderAspect] of [M].
///
/// Use only with [WatchReadAspectContext.watchProvidedAspect] and
/// [WatchReadContext.watchProvided].
final class ModelProvider<M> extends InheritedModel<ModelProviderAspect<M, dynamic>> {
  const ModelProvider({
    super.key,
    required this.model,
    required super.child,
    bool Function(ModelProvider<M> oldWidget)? updateShouldNotify,
  }) : _customUpdateShouldNotify = updateShouldNotify;

  final M model;
  final bool Function(ModelProvider<M> oldWidget)? _customUpdateShouldNotify;

  @override
  bool updateShouldNotify(covariant ModelProvider<M> oldWidget) {
    if (_customUpdateShouldNotify != null) {
      return _customUpdateShouldNotify(oldWidget);
    }
    return oldWidget.model != model;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant ModelProvider<M> oldWidget,
    Set<ModelProviderAspect<M, dynamic>> dependencies,
  ) {
    return dependencies.any((aspectGetter) {
      return aspectGetter.getAspect(oldWidget.model) !=
          aspectGetter.getAspect(model);
    });
  }
}

abstract mixin class ModelProviderAspect<M, V> {
  factory ModelProviderAspect.fromHandler(V Function(M object) getAspect) = _FromHandlerModelProviderAspect<M, V>;
  V getAspect(M object);
}

final class _FromHandlerModelProviderAspect<M, V> implements ModelProviderAspect<M, V> {
  _FromHandlerModelProviderAspect(V Function(M object) getAspect) : _getAspect = getAspect;

  final V Function(M object) _getAspect;

  @override
  V getAspect(M object) => _getAspect(object);
}

class ValueListenableProvider<T> extends StatelessWidget {
  const ValueListenableProvider({
    super.key,
    required this.notifier,
    required this.child,
  });

  final ValueListenable<T> notifier;
  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: notifier,
    builder: (context, value, child) {
      return Provider<T>(value: value, child: child!);
    },
    child: child,
  );
}

class ValueStreamProvider<T> extends StatefulWidget {
  const ValueStreamProvider({
    super.key,
    required this.stream,
    required this.child,
    required this.initialData,
  });

  final Stream<T> stream;
  final Widget child;
  final T Function() initialData;

  @override
  State<ValueStreamProvider<T>> createState() => _ValueStreamProviderState<T>();
}

class _ValueStreamProviderState<T> extends State<ValueStreamProvider<T>> {
  late T data;
  late final StreamSubscription<T> subscription;

  void onData(T value) {
    setState(() {
      data = value;
    });
  }

  @override
  void initState() {
    super.initState();
    data = widget.initialData();
    subscription = widget.stream.listen(onData);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Provider<T>(value: data, child: widget.child);
}

/// Provides simpler methods to watch what's [Provider] and [ModelProvider]
/// provide.
extension WatchReadContext on BuildContext {
  /// Watches a [T] provided by [Provider] or [ModelProvider].
  ///
  /// If [require] is true, it will include assert to check for non-null [T].
  ///
  /// Throws if [T] can't be found.
  T? watchProvided<T>({bool require = false}) {
    final inherited =
        dependOnInheritedWidgetOfExactType<Provider<T>>() ??
        dependOnInheritedWidgetOfExactType<ModelProvider<T>>();

    assert(() {
      if (require) {
        assert(inherited != null, 'No $T was found in context.');
      }
      return true;
    }());

    return switch (inherited) {
      Provider<T>(value: final value) => value,
      ModelProvider<T>(model: final model) => model,
      _ => null,
    };
  }

  /// Reads a [T] provided by [Provider] or [ModelProvider].
  ///
  /// If [require] is true, it will include assert to check for non-null [T].
  ///
  /// Throws if [T] can't be found.
  T? readProvided<T>({bool require = false}) {
    final inherited =
        findAncestorWidgetOfExactType<Provider<T>>() ??
        findAncestorWidgetOfExactType<ModelProvider<T>>();

    assert(() {
      if (require) {
        assert(inherited != null, 'No $T was found in context.');
      }
      return true;
    }());

    return switch (inherited) {
      Provider<T>(value: final value) => value,
      ModelProvider<T>(model: final model) => model,
      _ => null,
    };
  }
}

/// Provides simpler methods to watch what's [ModelProvider]
/// provides.
extension WatchReadAspectContext on BuildContext {
  /// Watches an aspect of [M] provided by [ModelProvider].
  ///
  /// If [require] is true, it will include assert to check for non-null [M].
  ///
  /// All type arguments are required.
  V? watchProvidedAspect<M, V>(
      ModelProviderAspect<M, V> aspect, {
    bool require = false,
  }) {
    final inherited = dependOnInheritedWidgetOfExactType<ModelProvider<M>>(
      aspect: aspect,
    );

    assert(() {
      if (require) {
        assert(
          inherited != null,
          'No $M found in context to get an aspect of $aspect from it.',
        );
      }
      return true;
    }());

    if (inherited == null) return null;

    return aspect.getAspect(inherited.model);
  }

  /// Reads an aspect of [M] provided by [ModelProvider].
  ///
  /// If [require] is true, it will include assert to check for non-null [M].
  ///
  /// All type arguments are required.
  V? readProvidedAspect<M, V>(
    ModelProviderAspect<M, V> aspect, {
    bool require = false,
  }) {
    final inherited = findAncestorWidgetOfExactType<ModelProvider<M>>();

    assert(() {
      if (require) {
        assert(
          inherited != null,
          'No $M found in context to get an aspect of $aspect from it.',
        );
      }
      return true;
    }());

    if (inherited == null) return null;

    return aspect.getAspect(inherited.model);
  }
}
