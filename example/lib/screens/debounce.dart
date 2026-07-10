import 'package:flutter/material.dart';
import 'package:store_keeper/store_keeper.dart';

import 'package:example/store.dart';

class Search extends Mutation<AppStore> with Debounce {
  final String query;
  Search(this.query);

  // Coalesce keystrokes: the first fires immediately, the rest within 500ms
  // are dropped, and only the latest one fires when the window closes. The
  // Debouncer interceptor (registered in main.dart) handles this.
  @override
  Duration get debounceTime => const Duration(milliseconds: 500);

  @override
  exec() {
    store.query = query;
  }
}

class DebounceExample extends StatelessWidget {
  const DebounceExample({super.key});

  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Search]);
    AppStore store = StoreKeeper.store as AppStore;

    return Scaffold(
      appBar: AppBar(title: Text("Debouncer")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Search",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => Search(value),
              ),
            ),
            Text("Searching for: ${store.query}"),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Type quickly in the field.\n"
                "The Search mutation fires on the first keystroke and then "
                "at most once per 500ms with the latest value.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
