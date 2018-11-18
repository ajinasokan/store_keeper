import 'package:flutter/material.dart';
import 'app.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StoreKeeperProvider(
          store: Store(),
          child: Main(),
        ),
      ),
    );
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    var store = StoreKeeper.of(context).getStore<Store>();
    StoreKeeper.of(context).notifyOn([IncrementA]);

    return Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(
        children: <Widget>[
//          UpdateOn<IncrementA>(
//            builder: (_) => Counter(
//                  name: "A",
//                  count: store.counterA,
//                  onIncrement: () => IncrementA(),
//                ),
//          ),
          UpdateOn<IncrementB>(
            builder: (_) => Counter(
                  name: "B",
                  count: store.counterB,
                  onIncrement: () => IncrementB(),
                ),
          ),
//          UpdateOn(
//            mutations: [IncrementB, IncrementA],
//            builder: (_) => Counter(
//                  name: "SUM",
//                  count: store.counterA + store.counterB,
//                  onIncrement: () => {},
//                ),
//          ),
          Counter(
            name: "A",
            count: store.counterA,
            onIncrement: () => IncrementA(),
          ),
          RaisedButton(onPressed: () {
//            var client = IOClient(
//                HttpClient()..connectionTimeout = Duration(seconds: 10));
//            client.send(http.Request("GET", Uri.parse("")));
          })
        ],
      ),
    );
  }
}

class Counter extends StatelessWidget {
  final int count;
  final VoidCallback onIncrement;
  final String name;

  Counter({this.name, this.count = 0, this.onIncrement});

  @override
  Widget build(BuildContext context) {
    print(name);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(count.toString()),
        RaisedButton(
          onPressed: onIncrement,
        )
      ],
    );
  }
}

void main() => runApp(App());
