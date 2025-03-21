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
            model: const MyModel(false, 0, 'asd'),
            child: Builder(
              builder: (context) {
                final foo = MyModelAspect.readFooOf(context);
                final zed = MyModelAspect.watchZedOf(context);
                final modelItself =
                    context.watchProvided<MyModel>(require: true)!;
                return Text('zed:$zed:foo:$foo:foo:${modelItself.bar}');
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('zed:asd:foo:false:foo:0'), findsOneWidget);
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

  static bool? readFooOf(BuildContext context) =>
      context.readProvidedAspect(MyModelAspect.foo);

  static String? watchZedOf(BuildContext context) =>
      context.watchProvidedAspect(MyModelAspect.zed);

  @override
  T getAspect(MyModel object) =>
      switch (this) {
            MyModelAspect.foo => object.foo,
            MyModelAspect.bar => object.bar,
            MyModelAspect.zed => object.zed,
          }
          as T;
}
