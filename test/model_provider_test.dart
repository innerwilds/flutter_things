import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_things/src/provider_things.dart';

void main() {
  testWidgets('Can read ModelProvider aspect', (tester) async {
    // Build an App with a Text widget that displays the letter 'H'.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModelProvider<MyModel>(
            model: const MyModel(false, 0, ''),
            child: Builder(
              builder: (context) {
                final foo = MyModelAspect.maybeFooOf(context);
                final modelItself =
                    context.watchProvided<MyModel>(require: true)!;
                return Text('foo:$foo:foo:${modelItself.bar}');
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('foo:false:foo:0'), findsOneWidget);
  });
}

class MyModel {
  const MyModel(this.foo, this.bar, this.zed);
  final bool foo;
  final int bar;
  final String zed;
}

enum MyModelAspect<T> implements ModelProviderAspect<MyModel, T> {
  foo<bool>(),
  bar<int>(),
  zed<String>();

  static bool? maybeFooOf(BuildContext context) => context
      .readProvidedAspect<MyModel, bool>(MyModelAspect.foo);

  @override
  T getAspect(MyModel object) => switch (this) {
    MyModelAspect.foo => object.foo,
    MyModelAspect.bar => object.bar,
    MyModelAspect.zed => object.zed,
  } as T;
}
