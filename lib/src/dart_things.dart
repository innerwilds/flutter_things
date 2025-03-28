import 'package:dart_things/dart_things.dart';
import 'package:flutter/widgets.dart';

/// Takes an [Initializer], calls it's [Initializer.ensureInitialized], takes a
/// future and waits for it's completion.
class InitializableBuilder extends StatefulWidget {
  /// Creates a widget that waits for [initializable] to be initialized.
  ///
  /// It is same as using [FutureBuilder], but this class can be extended,
  /// if [Initializer] changes it's API.
  const InitializableBuilder({
    super.key,
    required this.initializable,
    required this.builder,
  });

  final Initializer initializable;
  final Widget Function(BuildContext, AsyncSnapshot<void>) builder;

  @override
  State<InitializableBuilder> createState() => _InitializableBuilderState();
}

class _InitializableBuilderState extends State<InitializableBuilder> {
  Future<void>? _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = widget.initializable.ensureInitialized();
  }

  @override
  void dispose() {
    _initializationFuture = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializationFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return widget.builder(
            context,
            const AsyncSnapshot.waiting(),
          );
        }

        if (snap.hasError) {
          return widget.builder(
            context,
            AsyncSnapshot.withError(
              ConnectionState.done,
              snap.error!,
              snap.stackTrace!,
            ),
          );
        }

        return widget.builder(
          context,
          AsyncSnapshot.withData(
            ConnectionState.done,
            snap.data,
          ),
        );
      },
    );
  }
}
