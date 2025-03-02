import 'dart:async';
import 'dart:io';
import 'dart:ui' as io show Brightness, DisplayFeature;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart' as gestures show DeviceGestureSettings;
import 'package:flutter/widgets.dart' as wid;

/// Android device types.
enum AndroidType {
  /// Android mobile device
  mobile,

  /// Android-TV device
  tv,
}

/// Provides runtime detection of a specific platform.
///
/// Currently it is created only for recognizing Android TV based OSes.
/// In this case it will check for leanback feature. If you need more, use
/// something else.
abstract final class RuntimePlatform {
  static AndroidType? _androidType;

  static bool get isAndroidTV => androidType == AndroidType.tv;

  /// Initializes [RuntimePlatform]. Must be called as earlier as possible
  /// and after [WidgetsFlutterBinding.ensureInitialized].
  static FutureOr<void> initialize() async {
    await _initializeAndroidType();
  }

  static FutureOr<void> _initializeAndroidType() async {
    if (_androidType != null || !Platform.isAndroid) {
      return;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final isTV = androidInfo.systemFeatures.contains(
      'android.software.leanback',
    );

    _androidType = isTV ? AndroidType.tv : AndroidType.mobile;
  }

  /// Gets [AndroidType] of runtime platform.
  static AndroidType get androidType {
    if (_androidType != null) {
      return _androidType!;
    }
    throw StateError(
      'To use PlatformExtension you must once call '
      'PlatformExtension.initialize(), before using it.',
    );
  }
}

/// Useful things for a [wid.State].
extension ColiseumState<T extends wid.StatefulWidget> on wid.State<T> {
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

/// Provides read-only [wid.MediaQuery] things.
abstract final class MediaQueryReadOnly {
  wid.MediaQueryData? of(wid.BuildContext context) {
    return context.findAncestorWidgetOfExactType<wid.MediaQuery>()?.data;
  }

  wid.Size? sizeOf(wid.BuildContext context) => of(context)?.size;
  double? devicePixelRatioOf(wid.BuildContext context) =>
      of(context)?.devicePixelRatio;
  wid.TextScaler? textScalerOf(wid.BuildContext context) =>
      of(context)?.textScaler;
  io.Brightness? platformBrightnessOf(wid.BuildContext context) =>
      of(context)?.platformBrightness;
  wid.EdgeInsets? paddingOf(wid.BuildContext context) => of(context)?.padding;
  wid.EdgeInsets? viewPaddingOf(wid.BuildContext context) =>
      of(context)?.viewPadding;
  wid.EdgeInsets? viewInsetsOf(wid.BuildContext context) =>
      of(context)?.viewInsets;
  wid.EdgeInsets? systemGestureInsetsOf(wid.BuildContext context) =>
      of(context)?.systemGestureInsets;
  bool? alwaysUse24HourFormatOf(wid.BuildContext context) =>
      of(context)?.alwaysUse24HourFormat;
  bool? highContrastOf(wid.BuildContext context) => of(context)?.highContrast;
  bool? onOffSwitchLabelsOf(wid.BuildContext context) =>
      of(context)?.onOffSwitchLabels;
  bool? disableAnimationsOf(wid.BuildContext context) =>
      of(context)?.disableAnimations;
  bool? invertColorsOf(wid.BuildContext context) => of(context)?.invertColors;
  bool? accessibleNavigationOf(wid.BuildContext context) =>
      of(context)?.accessibleNavigation;
  bool? boldTextOf(wid.BuildContext context) => of(context)?.boldText;
  wid.NavigationMode? navigationModeOf(wid.BuildContext context) =>
      of(context)?.navigationMode;
  gestures.DeviceGestureSettings? gestureSettingsOf(wid.BuildContext context) =>
      of(context)?.gestureSettings;
  List<io.DisplayFeature>? displayFeaturesOf(wid.BuildContext context) =>
      of(context)?.displayFeatures;
  bool? supportsShowingSystemContextMenuOf(wid.BuildContext context) =>
      of(context)?.supportsShowingSystemContextMenu;
}
