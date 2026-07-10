import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';

import 'package:example/store.dart';

class Increment extends Mutation<AppStore> with RateLimit {
  // Allow this mutation to fire at most once per second; the RateLimiter
  // interceptor (registered in main.dart) drops the rest.
  @override
  Duration get rateLimitTime => const Duration(seconds: 1);

  @override
  exec() {
    store.count++;
  }
}

class RateLimiterExample extends StatelessWidget {
  const RateLimiterExample({super.key});

  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Increment]);
    AppStore store = StoreKeeper.store as AppStore;

    return Scaffold(
      appBar: AppBar(title: Text("Rate limiter")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("Count: ${store.count}"),
            ElevatedButton(
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
