import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_things/flutter_things.dart';

void main() {
  const heartPath =
      'm    0.91421453 , 0.50000053 -0.414214,0.414214    -0.414214 ,-0.414214 a0.29289353,0.29289353 0 0 1 0.414214, -0.414214 0.29289353,0.29289353 0   0 1 0.414214,0.414214 z';
  test('Heart path must be parsed without errors', () {
    expect(() {
      parsePath(heartPath);
    }, returnsNormally);
  });
}
