import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_things/src/provider_things.dart';

void main() {
  testWidgets('Can read ModelProvider aspect', (tester) async {
    // Build an App with a Text widget that displays the letter 'H'.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ModelProvider<MyModel, MyModelAspect>(
          model: const MyModel(false, 0, ''),
          child: Builder(
            builder: (context) {
              final foo = MyModelAspect.fooOf(context);
              return Text('foo:$foo');
            },
          ),
        ),
      ),
    ));

    expect(find.text('foo:false'), findsOneWidget);
  });
}

class MyModel {
  const MyModel(this.foo, this.bar, this.zed);
  final bool foo;
  final int bar;
  final String zed;
}

enum MyModelAspect implements ModelProviderAspect<MyModel> {
  foo(),
  bar(),
  zed();

  static bool fooOf(BuildContext context) => context.readProvidedAspect<MyModel, MyModelAspect, bool>(MyModelAspect.foo);

  @override
  dynamic getAspect(MyModel object) => switch(this) {
    MyModelAspect.foo => object.foo,
    MyModelAspect.bar => object.bar,
    MyModelAspect.zed => object.zed,
  };
}