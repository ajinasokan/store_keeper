# StoreKeeper

StoreKeeper is a state management library built for Flutter apps with focus on simplicity. It is heavily inspired by similar libraries in the JavaScript world. Here is a basic idea of how it works:

- Single Store to keep app's data
- Structured modifications to store with Mutations
- Widgets listen to mutations to rebuild themselves
- Enhance this process with Interceptors and SideEffects

Core of StoreKeeper is based on the [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html) widget from Flutter and it was initially developed as the backend for [Kite](https://play.google.com/store/apps/details?id=com.zerodha.kite3) in early 2018. Later it was detached to this library. Now it is in production for numerous other apps including [Coin](https://play.google.com/store/apps/details?id=com.zerodha.coin), [Olam](https://play.google.com/store/apps/details?id=com.olam) and [Hackly](https://play.google.com/store/apps/details?id=com.ajinasokan.hackly).

## Getting started

Add to your pubpsec:

```yaml
dependencies:
  ...
  store_keeper: ^1.0.0
```

Create a store:

```dart
import 'package:store_keeper/store_keeper.dart';

class AppStore extends Store {
  int count = 0;
}
```

Define mutations:

```dart
class Increment extends Mutation<AppStore> {
  exec() => store.count++;
}

class Multiply extends Mutation<AppStore> {
  final int by;

  Multiply({required this.by});

  exec() => store.count *= by;
}
```

Listen to mutations:

```dart
@override
Widget build(BuildContext context) {
  // Define when this widget should re render
  StoreKeeper.listen(context, to: [Increment, Multiply]);

  // Get access to the store
  final store = StoreKeeper.store as AppStore;

  return Text("${store.count}");
}
```

Complete example:

```dart
import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';

// Build store and make it part of app
void main() {
  runApp(StoreKeeper(
    store: AppStore(),
    child: MyApp(),
  ));
}

// Store definition
class AppStore extends Store {
  int count = 0;
}

// Mutations
class Increment extends Mutation<AppStore> {
  exec() => store.count++;
}

class Multiply extends Mutation<AppStore> {
  final int by;

  Multiply({required this.by});

  exec() => store.count *= by;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define when this widget should re render
    StoreKeeper.listen(context, to: [Increment, Multiply]);

    // Get access to the store
    final store = StoreKeeper.store as AppStore;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            ElevatedButton(
              child: Text("Increment"),
              onPressed: () {
                // Invoke mutation
                Increment();
              },
            ),
            ElevatedButton(
              child: Text("Multiply"),
              onPressed: () {
                // Invoke with params
                Multiply(by: 2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Documentation

- [Store](https://github.com/ajinasokan/store_keeper/blob/master/doc/store.md) - Where your apps's data is kept
- [Mutations](https://github.com/ajinasokan/store_keeper/blob/master/doc/mutations.md) - Logic that modifies Store
- [Widgets](https://github.com/ajinasokan/store_keeper/blob/master/doc/widgets.md) - Useful widgets for special cases
- [Side effects](https://github.com/ajinasokan/store_keeper/blob/master/doc/sideeffects.md) - Chained mutations
- [Interceptors](https://github.com/ajinasokan/store_keeper/blob/master/doc/interceptors.md) - Intercept execution of mutations
- [API Reference](https://pub.dev/documentation/store_keeper/latest/) - Complete list of APIs and usage