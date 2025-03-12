import 'dart:async';
import 'dart:io';
import 'dart:ui' as io show Brightness, DisplayFeature;

import 'package:dart_things/dart_things.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart' as gestures show DeviceGestureSettings;
import 'package:flutter/widgets.dart';

/// Android device types.
enum AndroidType {
  /// Android mobile device
  mobile,

  /// Android-TV device
  tv,
}

final class _RuntimePlatform extends RuntimePlatform with Initializer {
  late final AndroidType androidType;

  FutureOr<void> _initializeAndroidType() async {
    if (!Platform.isAndroid) {
      return;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final hasLeanback = androidInfo.systemFeatures.contains(
      'android.software.leanback',
    );

    androidType = hasLeanback ? AndroidType.tv : AndroidType.mobile;
  }

  @override
  Future<void> initialize() async {
    await _initializeAndroidType();
    super.initialize();
  }
}

/// Provides runtime detection of a specific platform.
abstract class RuntimePlatform {
  /// Whether current platform is an Android TV.
  ///
  /// Detection is based on whether leanback feature is present.
  bool get isAndroidTV => androidType == AndroidType.tv;

  abstract final AndroidType androidType;

  static _RuntimePlatform? _instance;
  static RuntimePlatform get instance {
    if (_instance == null) {
      throw FlutterError(
        'Call RuntimePlatform.ensureInitialized() before using it.',
      );
    }
    return _instance!;
  }

  /// Initializes [RuntimePlatform]. Must be called after
  /// [WidgetsFlutterBinding.ensureInitialized].
  static Future<void> ensureInitialized() async {
    if (_instance == null) {
      _instance = _RuntimePlatform();
      await _instance!.ensureInitialized();
    }
  }
}

/// Useful things for a [State].
extension ColiseumState<T extends StatefulWidget> on State<T> {
  /// sets state if this [State] is mounted.
  ///
  /// Use with safety.
  ///
  // TODO(innerwilds): add a bad case from THE app.
  void setStateIfMounted(void Function() cb) {
    if (mounted) {
      setState(cb);
    }
  }
}

/// Provides read-only [MediaQuery] things.
abstract final class MediaQueryReadOnly {
  static MediaQueryData? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<MediaQuery>()?.data;
  }
  static Size? sizeOf(BuildContext context) => of(context)?.size;
  static double? devicePixelRatioOf(BuildContext context) =>
      of(context)?.devicePixelRatio;
  static TextScaler? textScalerOf(BuildContext context) =>
      of(context)?.textScaler;
  static io.Brightness? platformBrightnessOf(BuildContext context) =>
      of(context)?.platformBrightness;
  static EdgeInsets? paddingOf(BuildContext context) => of(context)?.padding;
  static EdgeInsets? viewPaddingOf(BuildContext context) =>
      of(context)?.viewPadding;
  static EdgeInsets? viewInsetsOf(BuildContext context) =>
      of(context)?.viewInsets;
  static EdgeInsets? systemGestureInsetsOf(BuildContext context) =>
      of(context)?.systemGestureInsets;
  static bool? alwaysUse24HourFormatOf(BuildContext context) =>
      of(context)?.alwaysUse24HourFormat;
  static bool? highContrastOf(BuildContext context) => of(context)?.highContrast;
  static bool? onOffSwitchLabelsOf(BuildContext context) =>
      of(context)?.onOffSwitchLabels;
  static bool? disableAnimationsOf(BuildContext context) =>
      of(context)?.disableAnimations;
  static bool? invertColorsOf(BuildContext context) => of(context)?.invertColors;
  static bool? accessibleNavigationOf(BuildContext context) =>
      of(context)?.accessibleNavigation;
  static bool? boldTextOf(BuildContext context) => of(context)?.boldText;
  static NavigationMode? navigationModeOf(BuildContext context) =>
      of(context)?.navigationMode;
  static gestures.DeviceGestureSettings? gestureSettingsOf(BuildContext context) =>
      of(context)?.gestureSettings;
  static List<io.DisplayFeature>? displayFeaturesOf(BuildContext context) =>
      of(context)?.displayFeatures;
  static bool? supportsShowingSystemContextMenuOf(BuildContext context) =>
      of(context)?.supportsShowingSystemContextMenu;
}
