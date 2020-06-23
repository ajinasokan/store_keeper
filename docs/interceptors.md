## Interceptors

This is to do some action before or after execution of a Mutation. Structure of a Interceptor is like this:

```dart
abstract class Interceptor {
  bool beforeMutation(Mutation mutation);
  void afterMutation(Mutation mutation);
}
```

Functions in the class is self explanatory and both can modify the incoming mutation as well. In case of `beforeMutation` if you return `false`, execution of that mutation will be cancelled.

## Example - Rate Limiter

This example blocks increment from executing more than once a second. Similar to a debouncer.

```dart
class RateLimiter extends Interceptor {
  var lastIncOn = DateTime.now();

  @override
  bool beforeMutation(Mutation<Store> mutation) {
    if (mutation is Increment) {
      final now = DateTime.now();

      // if the last call was not before one second cancel
      // this execution
      if (now.difference(lastIncOn) < Duration(seconds: 1)) {
        return false;
      }

      lastIncOn = now;
    }
    return true;
  }

  @override
  void afterMutation(Mutation<Store> mutation) {}
}
```