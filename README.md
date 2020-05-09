# StoreKeeper

StoreKeeper is an easy and flexible state management system for Flutter apps. The API is structured in a way that it will not add a lot of boiler plate code regardless of the project size. StoreKeeper is based on the InheritedModel widget from Flutter and it was initially developed as the backend of [Kite](https://play.google.com/store/apps/details?id=com.zerodha.kite3).

It is an action oriented system. Which means it applies changes to the UI when an action is performed. On the other hand libraries like Redux triggers the render when there is modification in the data. 

## Store

 This is where all the data of your app stored. You can have only a single store in the app. If you want to divide the store, you can create more models and add their instances to this class.

```dart
class AppStore extends Store {
  int count = 0;
}
```

## Mutations

This is where the app's logic is written.

```dart
// Write it as a class
class Increment extends Mutation<AppStore> {
  exec() => store.count++;
}

// or write it as a function
void increment() {
  (StoreKeeper.store as AppStore).count++;
  StoreKeeper.notify(increment);
}
```

## Initialization

You can attach store to your app like this:

```dart
void main() {
  runApp(StoreKeeper(
    store: AppStore(),
    child: MyApp(),
  ));
}
```

## Listening

In your widget if you want to rebuild it whenever a mutation happens call `update` with list of mutations:

```dart
@override
Widget build(BuildContext context) {
  StoreKeeper.update(context, on: [Increment, Multiply]);
  var store = StoreKeeper.store as AppStore;

  return ...
}
```

## APIs

`StoreKeeper.store`

Returns the current instance of the store.

`StoreKeeper.update(BuildContext context, {List<Object> on})`

Rebuilds the widget with context everytime a mutation given to `on` is performed.

`StoreKeeper.getStreamOf(Object mutation)`

Returns a stream associated with the mutation which sends an update everytime the mutation is performed. Useful if you want to use it with a `StreamBuilder`. You can use `UpdateOn` widget which combines these ideas. This is useful if you want to update only a small piece of the screen.

```dart
UpdateOn(
  mutations: [increment, multiply],
  builder: (_) => Text("Count: ${store.count}"),
),
```

`StoreKeeper.notify(Object mutation)`

Notifies StoreKeeper that the mutation has performed. This will internally notify all the listeners of that mutation. Used when you write mutations in functions.

`StoreKeeper.mutate(Object key, Function(Store) mutation)`

An inline method to mutate a state. Key defines the name of the mutation. Example usage:

```dart
StoreKeeper.mutate("increment", (AppStore store) => store.count++);
```

## Simple Example

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

  Multiply({this.by});

  exec() => store.count *= by;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define when this widget should re render
    StoreKeeper.update(context, on: [Increment, Multiply]);

    // Get access to the store
    var store = StoreKeeper.store as AppStore;

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Count: ${store.count}"),
              RaisedButton(
                child: Text("Increment"),
                onPressed: () {
                  // Invoke mutation
                  Increment();
                },
              ),
              RaisedButton(
                child: Text("Decrement"),
                onPressed: () {
                  // Invoke mutation with params
                  Multiply(by: 2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## HTTP Requests

```dart
class FetchNews extends Mutation<AppStore> with HttpEffects<Response, Response> {
  int page;

  FetchNews({this.page = 1});

  exec() {
    return Request(
      url: "https://website.news/list.json",
      params: {
        "page": page.toString(),
      },
      success: Response(),
      fail: Response(),
    );
  }

  success(Response response) {
    print(response.json());
  }

  fail(Response response) {
    print(response.text());
  }

  exception(dynamic e, StackTrace s) {
    print(e);
    print(s);
  }
}
```

Create an abstract class like below to make the mutation more readable.

```dart
abstract class APIRequest<S extends Response, F extends Response>
    extends Mutation<AppStore> with HttpEffects<S, F> {}

class FetchNews extends APIRequest<Response, Response> {
  ...
}
```