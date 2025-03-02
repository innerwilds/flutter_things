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

final class ModelProvider<M, A extends ModelProviderAspect<M>>
    extends InheritedModel<A> {
  const ModelProvider({super.key, required this.model, required super.child});

  final M model;

  @override
  bool updateShouldNotify(covariant ModelProvider<M, A> oldWidget) {
    return oldWidget.model != model;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant ModelProvider<M, A> oldWidget,
    Set<A> dependencies,
  ) {
    return dependencies.any((aspectGetter) {
      return aspectGetter.getAspect(oldWidget.model) !=
          aspectGetter.getAspect(model);
    });
  }
}

abstract mixin class ModelProviderAspect<M> {
  dynamic getAspect(M object);
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
  /// Throws if [T] can't be found.
  T? watchProvided<T>() {
    final inherited =
        dependOnInheritedWidgetOfExactType<Provider<T>>() ??
        dependOnInheritedWidgetOfExactType<ModelProvider<T, dynamic>>();

    return switch (inherited) {
      Provider<T>(value: final value) => value,
      ModelProvider<T, dynamic>(model: final model) => model,
      _ => null,
    };
  }

  /// Reads a [T] provided by [Provider] or [ModelProvider].
  ///
  /// Throws if [T] can't be found.
  T? readProvided<T>() {
    final inherited =
        findAncestorWidgetOfExactType<Provider<T>>() ??
        findAncestorWidgetOfExactType<ModelProvider<T, dynamic>>();

    return switch (inherited) {
      Provider<T>(value: final value) => value,
      ModelProvider<T, dynamic>(model: final model) => model,
      _ => null,
    };
  }
}

/// Provides simpler methods to watch what's [ModelProvider]
/// provides.
extension WatchReadAspectContext on BuildContext {
  /// Watches an aspect of [M] provided by [ModelProvider].
  ///
  /// Throws if [M] can't be found.
  ///
  /// All type arguments are required.
  E? watchProvidedAspect<M, A extends ModelProviderAspect<M>, E>(A aspect) {
    final inherited = dependOnInheritedWidgetOfExactType<ModelProvider<M, A>>(
      aspect: aspect,
    );

    if (inherited == null) return null;

    return aspect.getAspect(inherited.model) as E;
  }

  /// Reads an aspect of [M] provided by [ModelProvider].
  ///
  /// Throws if [M] can't be found.
  ///
  /// All type arguments are required.
  E? readProvidedAspect<M, A extends ModelProviderAspect<M>, E>(A aspect) {
    final inherited = findAncestorWidgetOfExactType<ModelProvider<M, A>>();

    if (inherited == null) return null;

    return aspect.getAspect(inherited.model) as E;
  }
}
