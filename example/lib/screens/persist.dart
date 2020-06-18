import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path/path.dart' as path;
import 'package:store_keeper/store_keeper.dart';
import 'package:example/store.dart';

class Increment extends Mutation<AppStore> {
  exec() {
    store.count++;
  }
}

class Save extends Mutation<AppStore> {
  exec() async {
    final dataDir = await pathProvider.getApplicationDocumentsDirectory();
    final storeFile = File(path.join(dataDir.path, "store.json"));
    await storeFile.writeAsString(store.toJSON());
  }
}

class Load extends Mutation<AppStore> {
  exec() async {
    final dataDir = await pathProvider.getApplicationDocumentsDirectory();
    final storeFile = File(path.join(dataDir.path, "store.json"));
    store.fromJSON(await storeFile.readAsString());
  }
}

class PersistExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreKeeper.listen(context, to: [Increment, Save, Load]);
    AppStore store = StoreKeeper.store;

    return Scaffold(
      appBar: AppBar(title: Text("Persistance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            RaisedButton(
              child: Text("Increment"),
              onPressed: () {
                Increment();
              },
            ),
            RaisedButton(
              child: Text("Load"),
              onPressed: () {
                Load();
              },
            ),
            RaisedButton(
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
