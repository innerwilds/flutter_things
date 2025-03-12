import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_things/flutter_things.dart';
import 'package:flutter_things/src/value_aspect_listenable_builder.dart';

void main() {
  final selectionController = ItemSelectionController();
  const items = [1,2,3,4,5];
  final updatesCount = [0,0,0,0,0];

  group('ValueAspectListenableBuilder updates only changed aspects', () {
    testWidgets('', (tester) async {
      // Build an App with a Text widget that displays the letter 'H'.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final key = items[idx];
                return ValueAspectListenableBuilder(
                  valueListenable: selectionController,
                  getAspect: (selectedKeys) {
                    return selectedKeys.contains(key);
                  },
                  builder: (context, isSelected, _) {
                    updatesCount[idx]++;
                    return ListTile(
                      selected: isSelected,
                      title: Text(key.toString()),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(updatesCount, const [1,1,1,1,1]);

      selectionController.select(3);

      await tester.pump();

      expect(updatesCount, const [1,1,2,1,1]);

      selectionController..select(4)..select(5);

      await tester.pump();

      expect(updatesCount, const [1,1,2,2,2]);
    });
  });
}
