import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:store_keeper/store_keeper.dart';

void main() {
  testWidgets('increment number in text', (tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(
      MaterialApp(
        home: StoreKeeper(
          store: TestStore(),
          child: ExampleWidget(),
        ),
      ),
    );

    expect(find.text("count is 0"), findsOneWidget);
    Increment();
    await tester.pump();
    expect(find.text("count is 1"), findsOneWidget);
  });

  testWidgets('UpdateOn widget', (tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(
      MaterialApp(
        home: StoreKeeper(
          store: TestStore(),
          child: ExampleBuilderWidget(),
        ),
      ),
    );

    expect(find.text("count is 0"), findsOneWidget);
    Increment();
    await tester.pump();
    expect(find.text("count is 1"), findsOneWidget);
  });
}

class TestStore extends Store {
  int count = 0;
}

class Increment extends Mutation<TestStore> {
  @override
  void exec() {
    store.count++;
  }
}

class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Increment]);
    final store = StoreKeeper.store as TestStore;
    return Text("count is ${store.count}");
  }
}

class ExampleBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = StoreKeeper.store as TestStore?;
    return BuildOn(
      mutations: {Increment},
      builder: (_) => Text("count is ${store!.count}"),
    );
  }
}
