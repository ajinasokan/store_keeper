# StoreKeeper

StoreKeeper is an easy and flexible state management system for Flutter apps.

## Store

```dart
class AppStore extends Store {
  int count = 0;
}
```

## Mutations

```dart
class Increment extends Mutation<AppStore> {
  exec() => store.count++;
}

void increment() {
  (StoreKeeper.store as AppStore).count++;
  StoreKeeper.notify(increment);
}
```

## Initialization

```dart
void main() {
  runApp(StoreKeeper(
    store: AppStore(),
    child: MyApp(),
  ));
}
```

## Listening

```dart
StoreKeeper.update(context, on: [Increment, Multiply]);
```

## APIs

`StoreKeeper.store`

`StoreKeeper.update(BuildContext context, {List<Object> on})`

`StoreKeeper.getStreamOf(Object mutation)`

`StoreKeeper.notify(Object mutation)`

`StoreKeeper.mutate(Object key, Function(Store) mutation)`

## Widgets

```dart
StoreKeeper(
    store: AppStore(),
    child: MyApp(),
)
```

```dart
UpdateOn(
  mutations: [increment, multiply],
  builder: (_) => Text("Count: ${store.count}"),
),
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

## Mutations using functions

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
void increment() {
  (StoreKeeper.store as AppStore).count++;
  StoreKeeper.notify(increment);
}

void multiply({int by}) {
  (StoreKeeper.store as AppStore).count *= by;
  StoreKeeper.notify(multiply);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define when this widget should re render
    StoreKeeper.update(context, on: [increment, multiply]);

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
                  increment();
                },
              ),
              RaisedButton(
                child: Text("Decrement"),
                onPressed: () {
                  // Invoke mutation with params
                  multiply(by: 2);
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

## Project structure

```shell
mkdir lib/components
mkdir lib/screens
mkdir lib/mutations
mkdir lib/models
mkdir lib/constants
mkdir lib/resources
mkdir lib/framework

touch lib/components/index.dart
touch lib/screens/index.dart
touch lib/mutations/index.dart
touch lib/models/index.dart
touch lib/constants/index.dart
touch lib/resources/index.dart
touch lib/framework/index.dart
touch lib/app.dart
```

```dart
// app.dart
export 'package:store_keeper/store_keeper.dart';

export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter/rendering.dart';

export 'package:app/models/index.dart';
export 'package:app/mutations/index.dart';
export 'package:app/constants/index.dart';
export 'package:app/components/index.dart';
export 'package:app/screens/index.dart';
export 'package:app/resources/index.dart';
export 'package:app/framework/index.dart';
```

```dart
// main.dart
import 'package:app/app.dart';


void main() {
  runApp(
    StoreKeeper(
      store: AppStore(),
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    LoadStore();
  }

  @override
  Widget build(BuildContext context) {
    StoreKeeper.update(context, on: [
      LoadStore,
      ToggleNightMode,
    ]);
    var store = StoreKeeper.store as AppStore;
    if (!store.storeLoaded) return Container(color: Colors.white);

    var theme;
    if (store.nightMode) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      );
      theme = ThemeData.dark().copyWith(
        toggleableActiveColor: Colors.teal,
        accentColor: Colors.tealAccent,
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      );
      theme = ThemeData(
        primarySwatch: Colors.grey,
        primaryColorBrightness: Brightness.light,
        primaryColor: Colors.black,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      theme: theme,
      home: Main(),
    );
  }
}
```

```dart
abstract class Mutation extends Mutation<AppStore> {}

abstract class APIRequest<S extends Response, F extends Response>
    extends Mutation<AppStore> with HttpEffects<S, F> {}
```

```dart
// mutations.dart
import 'package:app/app.dart';

class LoadStore extends Mutation<AppStore> {
  Future<void> exec() async {
    var prefs = await SharedPreferences.getInstance();
    var json = prefs.getString("store");
    if (json != null) store.initFromJson(json);

    store.storeLoaded = true;
  }
}

class HackerNews extends APIRequest<StoryResponse, Response> {
  Request exec() {
    return Request(
      method: "GET",
      url: "https://hacker-news.firebaseio.com/v0/item/8863.json",
      params: {"print": "pretty"},
      success: StoryResponse(),
    );
  }

  void fail(Response response) {
    print("fail");
  }

  void success(StoryResponse response) {
    print(response.userId);
    print("success");
  }

  void error(Error err, Response response) {
    print(err.stackTrace);
    print("error");
  }
}

class StoryResponse extends Response {
  String userId = "";
  String title = "";
  int score = 0;

  void parse() {
    var data = toMap();
    userId = data["by"];
    score = data["score"];
    title = data["title"];
  }
}
```
