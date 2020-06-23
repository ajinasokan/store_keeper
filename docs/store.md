## Store

 This is where all the in-memory data of your app is stored. Mutations fetch data from APIs, databases etc. and keep it here.

```dart
class AppStore extends Store {
  int count = 0;
}
```

You can have only a single store in the app. If you want to divide the store, you can create more models and add their instances to this class. For example:

```dart
class ShopStore extends Store {
  final inventory = Inventory();

  final orders = Orders();

  final profile = Profile();
}
```

Reason for using a single store:

- Single source of truth
- Easily persist store by serializing it
- Jump between different instances of store like Redux time travel

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

This is essentially a global variable which means you should be a little bit careful while writing tests. You should not keep reference to store instance. Access should be restricted only though `StoreKeeper.store` getter, like below, to avoid some common mistakes.

```dart
AppStore store = StoreKeeper.store;
```