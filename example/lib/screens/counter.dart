import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class Increment extends Mutation<AppStore> {
  exec() {
    store.count++;
  }
}

class Multiply extends Mutation<AppStore> {
  final int by;

  Multiply({required this.by});

  exec() {
    store.count *= by;
  }
}

class Reset extends Mutation<AppStore> {
  exec() {
    store.count = 0;
  }
}

class CounterExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Increment, Multiply, Reset]);
    AppStore store = StoreKeeper.store as AppStore;

    return Scaffold(
      appBar: AppBar(title: Text("Counter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            ElevatedButton(
              child: Text("Increment"),
              onPressed: () {
                Increment();
              },
            ),
            ElevatedButton(
              child: Text("Multiply"),
              onPressed: () {
                Multiply(by: 2);
              },
            ),
            ElevatedButton(
              child: Text("Reset"),
              onPressed: () {
                Reset();
              },
            ),
          ],
        ),
      ),
    );
  }
}
