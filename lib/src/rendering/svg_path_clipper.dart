import 'package:flutter/rendering.dart';

final _numberRegex = RegExp(r'[+-]?(\d*\.\d+|\d+\.?\d*)([eE][+-]?\d+)?');
final _notACommand = RegExp(r'[^a-zA-Z]');
final _cache = <int, List<void Function(Path)>>{};

List<void Function(Path)> _parsePath(String path) {
  final set = <void Function(Path)>[];

  double takeNumber() {
    final match = _numberRegex.matchAsPrefix(path);
    assert(match != null);
    final number = path.substring(0, match!.end);
    path = path.substring(match.end).trimLeft();
    return double.parse(number);
  }

  while (path.isNotEmpty) {

    final command = path.substring(0, 1);
    path = path.substring(1);

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
              path.relativeQuadraticBezierTo(
                x1,
                y1,
                x2,
                y2,
              );
            });
          } else {
            set.add((path) {
              path.quadraticBezierTo(
                x1,
                y1,
                x2,
                y2,
              );
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
              path.relativeCubicTo(
                x1,
                y1,
                x2,
                y2,
                x3,
                y3,
              );
            });
          } else {
            set.add((path) {
              path.cubicTo(
                x1,
                y1,
                x2,
                y2,
                x3,
                y3,
              );
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
              path.relativeArcToPoint(Offset(x, y),
                radius: Radius.elliptical(rx, ry),
                rotation: rotation,
                largeArc: largeArc,
                clockwise: sweepFlag);
            });
          } else {
            set.add((path) {
              path.arcToPoint(Offset(x, y),
                  radius: Radius.elliptical(rx, ry),
                  rotation: rotation,
                  largeArc: largeArc,
                  clockwise: sweepFlag);
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
  return _cache[path.hashCode] ??= _parsePath(path);
}

class SvgPathClipper extends CustomClipper<Path> {
  SvgPathClipper(this.originalSize, String path, {
    this.flip = false,
  }) : instructionSet = _parsePathAndCache(path);

  final Size originalSize;
  final bool flip;
  final List<void Function(Path)> instructionSet;

  @override
  Path getClip(Size size) {
    final pathObj = Path();

    for (var apply in instructionSet) {
      apply(pathObj);
    }

    final scaleX = size.width / originalSize.width;
    final scaleY = size.height / originalSize.height;

    final matrix = Matrix4.identity()
      ..scale(flip ? -scaleX : scaleX, scaleY);

    return pathObj.transform(matrix.storage);
  }

  @override
  bool shouldReclip(SvgPathClipper oldClipper) {
    return
      instructionSet != oldClipper.instructionSet ||
      originalSize != oldClipper.originalSize ||
      flip != oldClipper.flip;
  }
}