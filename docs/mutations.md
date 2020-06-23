## Mutations

This is where the app's logic is written. Everything inside `exec` function is executed when you create an object of the class.

```dart
class Increment extends Mutation<AppStore> {
  exec() => store.count++;
}
```

Execution can be async too. If you return a `Future` for `exec`, StoreKeeper will await that.

```dart
class ExportReport extends Mutation<AppStore> {
  // This mutation will be notified to widgets
  // only after this is done.
  Future<void> exec() async {
    await MyFile().write(store.report);
  }
}
```

## Simple Chaining

To execute some other mutation after one is done you can use `later` call.

```dart
class ChangeAvatar extends Mutation<AppStore> {
  exec() {
    final avatar = Image().crop();
    
    // This will be executed once ChangeAvatar is finished
    later(() => UploadAvatar(avatar));

    avatar.save();
  }
}
```

## Catching exceptions

If exceptions happen in `exec` they are cought and logged if app is in debug mode. To change the behaviour you can either override `exception` callback or create a custom `Mutation` class with specific features such as reporting crash to third party service or showing a screen with crash details to the user etc.

```dart
class Divide extends Mutation<AppStore> {
  exec() {
    store.count = store.count/store.factor;
  }

  exception(dynamic e, StackTrace s) {
    CrashReporting.report(e, s);
  }
}
```

## Listening

In your widget if you want to rebuild it after a mutation is executed call `listen` with list of mutations:

```dart
@override
Widget build(BuildContext context) {
  StoreKeeper.listen(context, to: [Increment]);

  return ...
}
```

If the same mutation happens multiple times in a very short span of time widgets will receive it only once. StoreKeeper just notifies that mutation has executed. Any data related to that should be stored and collected from the store.

This behaviour is similar to `setState` where you can call it multiple times but it will trigger only one rebuild in a render cycle.