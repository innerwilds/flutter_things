import 'package:flutter/widgets.dart';

/// Provides preferred [ContrastLevel] to use for your
/// theme.
class Contrast extends InheritedWidget {
  /// Provides [ContrastLevel] to descendants.
  ///
  /// Provide it to use different contrast for your theme.
  /// You also need for your theme to support different contrasts.
  /// You need to change theme by hand, because it's only provider
  /// of preferred [ContrastLevel].
  const Contrast({
    required this.level,
    required super.child, super.key,
  });

  /// Contrast level.
  final ContrastLevel level;

  /// Returns [ContrastLevel] based on:
  ///   1. Ancestor. If there is [Contrast] ancestor in [context],
  ///      it's [Contrast.level] will be returned.
  ///   2. Platform. If there is no [Contrast] ancestor in [context],
  ///      it will return:
  ///      2.1. [ContrastLevel.normal] if platform is not provide
  ///           contrast preference.
  ///      2.2. [ContrastLevel.high] if platform provides
  ///           this preferences. Only available on iOS.
  static ContrastLevel of(BuildContext context) {
    final contrast =
        context.dependOnInheritedWidgetOfExactType<Contrast>();

    if (contrast == null) {
      return switch(MediaQuery.highContrastOf(context)) {
        true => ContrastLevel.high,
        false => ContrastLevel.normal,
      };
    }

    return contrast.level;
  }

  @override
  bool updateShouldNotify(Contrast old) {
    return level != old.level;
  }
}

/// Contrast level.
enum ContrastLevel {
  /// Normal contrast.
  normal,

  /// Medium contrast.
  medium,

  /// High contrast.
  high,
}