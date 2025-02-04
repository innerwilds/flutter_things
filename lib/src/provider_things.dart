import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

sealed class Provider<T> extends InheritedWidget {
  const Provider._({
    super.key,
    required super.child,
  });

  const factory Provider({
    Key? key,
    required Widget child,
    required T value,
  }) = _StaticProviderValue<T>;

  const factory Provider.valueGetter({
    Key? key,
    required Widget child,
    required ValueGetter<T> valueGetter,
    required ValueGetter<String> hashGetter,
  }) = _ValueGetterProviderValue<T>;

  T get value;
}

class _ValueGetterProviderValue<T> extends Provider<T> {
  const _ValueGetterProviderValue({
    super.key,
    required super.child,
    required this.valueGetter,
    required this.hashGetter,
  }) : super._();

  /// Will be used in [updateShouldNotify].
  /// Should represent what's [valueGetter] return.
  final ValueGetter<String> hashGetter;

  /// Value getter for lazy loading.
  final ValueGetter<T> valueGetter;

  @override
  bool updateShouldNotify(_ValueGetterProviderValue oldWidget) {
    return oldWidget.hashGetter() != hashGetter();
  }

  @override
  T get value => valueGetter();
}

final class _StaticProviderValue<T> extends Provider<T> {
  const _StaticProviderValue({
    super.key,
    required super.child,
    required this.value,
  }) : super._();

  @override
  final T value;

  @override
  bool updateShouldNotify(_StaticProviderValue oldWidget) {
    return oldWidget.value != value;
  }
}

class ValueListenableProvider<T> extends StatelessWidget {
  ValueListenableProvider({
    super.key,
    required this.notifier,
    required this.child,
  }) {
    print("ValueListenableProvider is used for notifier ${notifier.hashCode}");
  }

  final ValueListenable<T> notifier;
  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: notifier,
    builder: (context, value, child) {
      print("ValueListenableBuilder: $T just changed");
      return Provider<T>(
        value: value,
        child: child!,
      );
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
  bool isDataSet = false;
  late final StreamSubscription<T> subscription;

  void onData(T value) {
    setState(() {
      data = value;
      isDataSet = true;
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
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) => Provider<T>(
    value: data,
    child: widget.child,
  );
}

extension WatchReadContext on BuildContext {
  T watch<T>() {
    final inherited = dependOnInheritedWidgetOfExactType<Provider<T>>();

    print("Watching for $T...");

    assert(inherited != null, "Can't find Provider<$T> ancestor");

    return inherited!.value;
  }

  T read<T>() {
    var inherited = findAncestorWidgetOfExactType<Provider<T>>()?.value;

    assert(inherited != null, "Can't find Provider<$T> ancestor");

    return inherited!;
  }

  T? readOrNull<T>() {
    final inherited = findAncestorWidgetOfExactType<Provider<T>>();
    return inherited?.value;
  }
}