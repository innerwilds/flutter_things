import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as wid;

/// Android device types.
enum AndroidType {
  /// Android mobile device
  mobile,

  /// Android-TV device
  tv,
}

AndroidType? _androidType;

/// Provides runtime detection of platform, rather than compile-time.
abstract final class RuntimePlatform {
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
    final isTV =
        androidInfo.systemFeatures.contains('android.software.leanback');

    _androidType = isTV ? AndroidType.tv : AndroidType.mobile;
  }

  /// Gets [AndroidType] of runtime platform.
  static AndroidType get androidType {
    if (_androidType != null) {
      return _androidType!;
    }
    throw StateError('To use PlatformExtension you must once call '
        'PlatformExtension.initialize(), before using it.');
  }
}

extension StateExtensions<T extends wid.StatefulWidget> on wid.State<T> {
  void setStateIfMounted(void Function() cb) {
    if (mounted) {
      setState(cb);
    }
  }
}

extension MediaQueryOnBuildContext on wid.BuildContext {
  wid.MediaQueryData? get readMediaQuery {
    return findAncestorWidgetOfExactType<wid.MediaQuery>()?.data;
  }
  wid.MediaQueryData? get watchMediaQuery {
    return dependOnInheritedWidgetOfExactType<wid.MediaQuery>()?.data;
  }
}