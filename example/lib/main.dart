import 'package:example/screens/apicall.dart';
import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';

import 'package:example/screens/callbacks.dart';
import 'package:example/screens/counter.dart';
import 'package:example/screens/navigation.dart';
import 'package:example/screens/persist.dart';
import 'package:example/store.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Widget item({
    BuildContext context,
    String title,
    String body,
    WidgetBuilder builder,
  }) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: builder));
      },
      title: Text(title),
      subtitle: Text(body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("StoreKeeper")),
      body: ListView(
        children: <Widget>[
          item(
            context: context,
            builder: (_) => CounterExample(),
            title: "Counter - lib/screens/counter.dart",
            body: "Simple example for defining and executing mutations",
          ),
          item(
            context: context,
            builder: (_) => CallbackExample(),
            title: "Callback - lib/screens/callbacks.dart",
            body: "Executing a callback with Scaffold's "
                "widget for showing snackbar",
          ),
          item(
            context: context,
            builder: (_) => NavigationExample(),
            title: "Navigation - lib/screens/navigation.dart",
            body: "Dismissing a route after execution of a "
                "mutation",
          ),
          item(
            context: context,
            builder: (_) => PersistExample(),
            title: "Persist - lib/screens/persist.dart",
            body: "Example to show a simple way to persist "
                "store data",
          ),
          item(
            context: context,
            builder: (_) => APICallExample(),
            title: "API Call - lib/screens/apicall.dart",
            body: "API call fetch. Show progress indicator while "
                "fetching. Show snackbar on error.",
          ),
        ],
      ),
    );
  }
}
