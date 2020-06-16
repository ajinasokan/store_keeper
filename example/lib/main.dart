import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';
import 'store.dart';
import 'mutations.dart';

void main() {
  runApp(
    StoreKeeper(
      store: AppStore(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Increment, Multiply, Reset]);
    AppStore store = StoreKeeper.store;

    return Scaffold(
      appBar: AppBar(title: Text("StoreKeeper")),
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
