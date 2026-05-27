import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as ppath;
import 'package:path/path.dart' as ppath;
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class Increment extends Mutation<AppStore> {
  @override
  exec() {
    store.count++;
  }
}

class Save extends Mutation<AppStore> {
  @override
  exec() async {
    final dataDir = await ppath.getApplicationDocumentsDirectory();
    final storeFile = File(ppath.join(dataDir.path, "store.json"));
    await storeFile.writeAsString(store.toJSON());
  }
}

class Load extends Mutation<AppStore> {
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
    StoreKeeper.listen(context, to: [Increment, Save, Load]);
    AppStore store = StoreKeeper.store as AppStore;

    return Scaffold(
      appBar: AppBar(title: Text("Persistance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            ElevatedButton(
              child: Text("Increment"),
              onPressed: () {
                Increment();
              },
            ),
            ElevatedButton(
              child: Text("Load"),
              onPressed: () {
                Load();
              },
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                Save();
              },
            ),
          ],
        ),
      ),
    );
  }
}
