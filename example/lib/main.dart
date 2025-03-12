import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_things/flutter_things.dart';

late final ThreeStateAppRunner appRunner;

Widget threeStateTransitionBuilder(
  Widget? fromWidget,
  Widget toWidget,
  ThreeState from,
  ThreeState to,
  Animation<double> animation,
) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        Widget transition = Opacity(opacity: 1.0 - animation.value, child: child);

        switch (from) {
          case ThreeState.splash:
            switch(to) {
              case ThreeState.splash:
                break;
              case ThreeState.main:
              case ThreeState.exit:
                transition = Transform.scale(
                  scale: 1.0 + animation.value,
                  child: transition,
                );
            }
          case ThreeState.main:
            switch (to) {
              case ThreeState.main:
              case ThreeState.splash:
                break;
              case ThreeState.exit:
                transition = ColorFiltered(
                  colorFilter: ColorFilter.mode(Color.from(
                      alpha: 1.0 - animation.value,
                      red: 0, green: 0, blue: 0), BlendMode.difference),
                  child: transition,
                );
            }
          case ThreeState.exit:
            final matrix = Matrix4.identity()
              ..rotateX(animation.value * 180 * math.pi / 180)
              ..rotateY(animation.value * 180 * math.pi / -180);
            transition = ImageFiltered(
              imageFilter: ImageFilter.matrix(
                matrix.storage,
              ),
              child: transition,
            );
        }

        return Stack(
          children: [
            toWidget,
            if (animation.value != 1.0)
              transition,
          ],
        );
      },
      child: fromWidget,
    ),
  );
}

void main() {
  final loadingNotifier = ValueNotifier(0.0);
  late Completer<bool> _confirmExit;
  late Timer _exitTimer;

  appRunner = ThreeStateAppRunner(
    transitionDuration: Duration(seconds: 1),
    transitionCurve: Curves.linear,
    transitionBuilder: threeStateTransitionBuilder,
    onChange: (from, to) async {
      if (to == ThreeState.exit) {
        loadingNotifier.value = 1.0;
        _confirmExit = Completer();
        _exitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          loadingNotifier.value -= 0.2;
          if (loadingNotifier.value <= 0.0) {
            if (!_confirmExit.isCompleted) {
              _confirmExit.complete(true);
            } else {
              exit(0);
            }
          }
        });
        if (await _confirmExit.future) {
          exit(0);
        } else {
          _exitTimer.cancel();
          appRunner.go(ThreeState.main);
        }
      } else if(to == ThreeState.splash) {
        loadingNotifier.value = 0;
        while (loadingNotifier.value < 1.0) {
          await Future.delayed(const Duration(milliseconds: 100));
          loadingNotifier.value += math.Random().nextDouble().clamp(0, 0.1);
        }
        appRunner.go(ThreeState.main);
      }
    },
    builder: (context, target) {
      return MaterialApp(
        theme: switch(target) {
          ThreeState.splash => ThemeData.light(),
          ThreeState.main => ThemeData.light(),
          ThreeState.exit => ThemeData.dark(),
        },
        home: switch(target) {
          ThreeState.splash => Scaffold(body: Center(child: ValueListenableBuilder(
              valueListenable: loadingNotifier,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  year2023: false,
                  value: value,
                );
              }
          ))),
          ThreeState.main => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () => appRunner.go(ThreeState.splash),
                    child: Text('Splash'),
                  ),
                  FilledButton(
                    onPressed: () {
                      appRunner.go(ThreeState.exit);
                    },
                    child: Text('Exit'),
                  ),
                ],
              ),
            ),
          ),
          ThreeState.exit => Scaffold(body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ValueListenableBuilder(
                    valueListenable: loadingNotifier,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        year2023: false,
                        value: value,
                      );
                    }
                ),
                FilledButton(
                  onPressed: () {
                    _confirmExit.complete(true);
                  },
                  child: Text("I'm sure."),
                ),
                OutlinedButton(
                  onPressed: () {
                    _confirmExit.complete(false);
                  },
                  child: Text("Don't exit!"),
                ),
              ],
            ),
          )),
        },
      );
    },
  );

  appRunner.run(ThreeState.splash);
}
