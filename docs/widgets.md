## BuildOn

A helper widget built on top of `StreamBuilder` to rebuild a small part of the screen after execution of given mutations.

```dart
@override
Widget build(BuildContext context) {
    AppStore store = StoreKeeper.store;

    return BuildOn(
        mutations: {Increment},
        builder: (_) => Text("${store.count}"),
    );
}
```

## NotifyOn

A helper widget to get callbacks after execution of mutations. Useful for handling actions connected to context such as showing SnackBar or navigating to a route etc.

```dart
class CallmeBack extends Mutation<AppStore> {
  String message;

  exec() {
    message = "Hello from callback";
  }
}

... 

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: NotifyOn(
      mutations: {
        CallmeBack: (ctx, mut) {
          final message = (mut as CallmeBack).message;
          Scaffold.of(ctx).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      child: ...,
    ),
  );
}
```