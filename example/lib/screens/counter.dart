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

  Multiply({this.by});

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
    AppStore store = StoreKeeper.store;

    return Scaffold(
      appBar: AppBar(title: Text("Counter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            RaisedButton(
              child: Text("Increment"),
              onPressed: () {
                Increment();
              },
            ),
            RaisedButton(
              child: Text("Multiply"),
              onPressed: () {
                Multiply(by: 2);
              },
            ),
            RaisedButton(
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
