import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as ppath;
import 'package:path/path.dart' as ppath;
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class IncrementCount extends Mutation<AppStore> {
  @override
  exec() {
    store.count++;
  }
}

/// Writes the store to disk. Dispatched by the StorePersister interceptor in
/// main.dart so it runs automatically (and debounced) after [IncrementCount].
class SaveStore extends Mutation<AppStore> {
  @override
  exec() async {
    final dataDir = await ppath.getApplicationDocumentsDirectory();
    final storeFile = File(ppath.join(dataDir.path, "store.json"));
    await storeFile.writeAsString(store.toJSON());
  }
}

class LoadStore extends Mutation<AppStore> {
  @override
  exec() async {
    final dataDir = await ppath.getApplicationDocumentsDirectory();
    final storeFile = File(ppath.join(dataDir.path, "store.json"));
    store.fromJSON(await storeFile.readAsString());
  }
}

class PersistExample extends StatelessWidget {
  const PersistExample({super.key});

  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [IncrementCount, LoadStore]);
    AppStore store = StoreKeeper.store as AppStore;

    return Scaffold(
      appBar: AppBar(title: Text("Persistance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            ElevatedButton(
              child: Text("IncrementCount"),
              onPressed: () {
                IncrementCount();
              },
            ),
            ElevatedButton(
              child: Text("Load"),
              onPressed: () {
                LoadStore();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "IncrementCount saves the store automatically via the "
                "StorePersister interceptor (debounced). Restart the app "
                "and tap Load to restore.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
