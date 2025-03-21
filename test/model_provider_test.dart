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
            model: const MyModel(false, null, 'asd'),
            child: Builder(
              builder: (context) {
                final foo = MyModelAspect.readFooOf(context);
                final zed = MyModelAspect.watchZedOf(context);
                final bar = MyModelAspect.watchBarOf(context);
                return Text('zed:$zed:foo:$foo:bar:$bar');
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('zed:asd:foo:false:bar:null'), findsOneWidget);
  });
}

class MyModel {
  const MyModel(this.foo, this.bar, this.zed);
  final bool foo;
  final int? bar;
  final String zed;
}

enum MyModelAspect<T> implements ModelProviderAspect<MyModel, T> {
  foo<bool>(),
  bar<int?>(),
  zed<String>();

  static bool? readFooOf(BuildContext context) =>
      context.readProvidedAspect(MyModelAspect.foo);

  static int? watchBarOf(BuildContext context) =>
      context.watchProvidedAspect(MyModelAspect.bar);

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
