import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_things/flutter_things.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Callbacks])
import 'item_selection_controller_test.mocks.dart';

void main() {
  late ItemSelectionController<BigInt> controller;

  setUp(() {
    controller = ItemSelectionController<BigInt>();
  });

  test('Basic operations works normally', () {
    final callbacks = MockCallbacks();
    final changesListener = callbacks.changesListener;
    controller.addListener(changesListener);

    controller.select(BigInt.one); // notifies
    expect(controller.isSelected(BigInt.one), true);

    controller.unselect(BigInt.zero); // not notifies
    expect(controller.isSelected(BigInt.zero), false);

    controller.unselect(BigInt.one); // notifies
    expect(controller.isSelected(BigInt.one), false);

    controller.toggle(BigInt.two); // notifies
    expect(controller.isSelected(BigInt.two), true);

    controller.toggle(BigInt.two); // notifies
    expect(controller.isSelected(BigInt.two), false);

    expect(controller.value.isEmpty, true);

    controller.selectAll({ BigInt.two, BigInt.one, BigInt.zero }); // notifies
    expect(controller.isSelected(BigInt.two), true);

    controller.selectAll({ BigInt.two }); // not notifies
    expect(controller.isSelected(BigInt.two), true);

    controller.unselectAll({ BigInt.zero }); // notifies
    expect(controller.isSelected(BigInt.zero), false);

    verifyInOrder([
      callbacks.changesListener(),
      callbacks.changesListener(),
      callbacks.changesListener(),
      callbacks.changesListener(),
      callbacks.changesListener(),
      callbacks.changesListener(),
    ]);
  });
}

abstract class Callbacks {
  void changesListener();
}
