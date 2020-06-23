import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';

import 'package:example/store.dart';

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

class Increment extends Mutation<AppStore> {
  exec() {
    store.count++;
  }
}

class RateLimiterExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Increment]);
    AppStore store = StoreKeeper.store;

    return Scaffold(
      appBar: AppBar(title: Text("Rate limiter")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Count: ${store.count}"),
            RaisedButton(
              child: Text("Increment"),
              onPressed: () => Increment(),
            ),
            Text("Tap Increment multiple times a second.\n"
                "But it will trigger only once per second.")
          ],
        ),
      ),
    );
  }
}
