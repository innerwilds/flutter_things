import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

const _number = r'[+-]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][+-]?\d+)?';
final _numberRegex = RegExp(_number);
final _notACommand = RegExp('[^a-zA-Z]');
final _cache = <Object, List<void Function(Path)>>{};

/// Simple SVG path g attribute parser, it only supports: mM, sS, cC, aA, zZ.
///
/// It will give you instruction set to apply to a [Path].
///
/// It is intended to use with simple figures that can be drawn using only above
/// commands.
@visibleForTesting
List<void Function(Path)> parsePath(String pathToParse) {
  final set = <void Function(Path)>[];

  var path = pathToParse;

  void maySkipComma() {
    if (path.startsWith(',')) {
      path = path.substring(1);
    }
  }

  void trimLeft() {
    path = path.trimLeft();
  }

  double takeNumber() {
    final match = _numberRegex.matchAsPrefix(path);
    assert(match != null);
    final number = path.substring(0, match!.end);
    path = path.substring(match.end);
    trimLeft();
    maySkipComma();
    trimLeft();
    return double.parse(number);
  }

  path = path.trim();

  while (path.isNotEmpty) {
    final command = path.substring(0, 1);
    path = path.substring(1).trimLeft();

    switch (command) {
      case 'M':
      case 'm':
        final isRelative = command == 's';
        while (path.startsWith(_notACommand)) {
          final x = takeNumber();
          final y = takeNumber();
          if (isRelative) {
            set.add((path) {
              path.relativeMoveTo(x, y);
            });
          } else {
            set.add((path) {
              path.moveTo(x, y);
            });
          }
        }
        break;
      case 's':
      case 'S':
        final isRelative = command == 's';
        while (path.startsWith(_notACommand)) {
          final x1 = takeNumber();
          final y1 = takeNumber();
          final x2 = takeNumber();
          final y2 = takeNumber();

          if (isRelative) {
            set.add((path) {
              path.relativeQuadraticBezierTo(x1, y1, x2, y2);
            });
          } else {
            set.add((path) {
              path.quadraticBezierTo(x1, y1, x2, y2);
            });
          }
        }
        break;
      case 'C':
      case 'c':
        final isRelative = command == 'c';
        while (path.startsWith(_notACommand)) {
          final x1 = takeNumber();
          final y1 = takeNumber();
          final x2 = takeNumber();
          final y2 = takeNumber();
          final x3 = takeNumber();
          final y3 = takeNumber();
          if (isRelative) {
            set.add((path) {
              path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
            });
          } else {
            set.add((path) {
              path.cubicTo(x1, y1, x2, y2, x3, y3);
            });
          }
        }
        break;
      case 'A':
      case 'a':
        final isRelative = command == 'a';
        while (path.startsWith(_notACommand)) {
          final rx = takeNumber();
          final ry = takeNumber();
          var rotation = takeNumber();
          final largeArc = takeNumber() == 1;
          final sweepFlag = takeNumber() == 1;
          final x = takeNumber();
          final y = takeNumber();

          // (rx ry x-axis-rotation large-arc-flag sweep-flag x y)+

          if (isRelative) {
            set.add((path) {
              path.relativeArcToPoint(
                Offset(x, y),
                radius: Radius.elliptical(rx, ry),
                rotation: rotation,
                largeArc: largeArc,
                clockwise: sweepFlag,
              );
            });
          } else {
            set.add((path) {
              path.arcToPoint(
                Offset(x, y),
                radius: Radius.elliptical(rx, ry),
                rotation: rotation,
                largeArc: largeArc,
                clockwise: sweepFlag,
              );
            });
          }
        }
        break;
      case 'z':
      case 'Z':
        set.add((path) {
          path.close();
        });
        break;
    }
  }

  return set;
}

List<void Function(Path)> _parsePathAndCache(String path) {
  return _cache[_cacheKey(path)] ??= parsePath(path);
}

void _evictCache(String path) => _cache.remove(_cacheKey(path));

Object _cacheKey(String path) => path.hashCode;

/// Path clipper based on https://www.w3.org/TR/SVG2/paths.html#PathData.
/// Not stable.
class SvgPathClipper extends CustomClipper<Path> {
  /// Main ctor.
  ///
  /// [originalSize] here is a bound in which path was drawn.
  ///
  /// Using [flipX] you can flip it horizontally.
  /// Using [flipY] you can flip it horizontally.
  ///
  /// A [path] is SVG path as in 'd' attribute of 'path' element.
  /// It will be parsed in an instructions set and cached for future usage.
  /// To clean that cache, use [SvgPathClipper.evictCache].
  SvgPathClipper(
    this.originalSize,
    String path, {
    this.flipX = false,
    this.flipY = false,
  }) : instructionSet = _parsePathAndCache(path);

  final Size originalSize;
  final bool flipX;
  final bool flipY;
  final List<void Function(Path)> instructionSet;

  static void evictCache(String path) => _evictCache(path);

  @override
  Path getClip(Size size) {
    final pathObj = Path();

    for (final apply in instructionSet) {
      apply(pathObj);
    }

    final scaleX = size.width / originalSize.width;
    final scaleY = size.height / originalSize.height;

    final matrix =
        Matrix4.identity()
          ..scale(flipX ? -scaleX : scaleX, flipY ? -scaleY : scaleY);

    return pathObj.transform(matrix.storage);
  }

  @override
  bool shouldReclip(SvgPathClipper oldClipper) {
    return instructionSet != oldClipper.instructionSet ||
        originalSize != oldClipper.originalSize ||
        flipY != oldClipper.flipY ||
        flipX != oldClipper.flipX;
  }
}
