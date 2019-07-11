import 'dart:async';
import 'package:flutter/material.dart';
import 'inventory.dart';
import 'inherited_model.dart';
import 'mutation.dart';

export 'inventory.dart' show Store;
export 'mutation.dart';
export 'update_on.dart';

class StoreKeeper extends StatelessWidget {
  final Widget child;

  static Stream get updates => Inventory.storeUpdater.stream;

  static Store get store => Inventory.storeHandle;

  static void mutate(Object key, Function(Store) mutation) {
    mutation(StoreKeeper.store);
    notify(key);
  }

  static void notify(Object mutation) {
    getStreamOf(mutation.hashCode).add(null);

    Mutation.recent.add(mutation.hashCode);
    Inventory.storeUpdater.add(mutation.hashCode);
  }

  static StreamController<Null> getStreamOf(Object mutation) {
    if (!Inventory.streams.containsKey(mutation.hashCode))
      Inventory.streams[mutation.hashCode] = StreamController<Null>.broadcast();
    return Inventory.streams[mutation.hashCode];
  }

  static void update(BuildContext context, {List<Object> on}) {
    on.forEach((m) => context.inheritFromWidgetOfExactType(
          StoreKeeperModel,
          aspect: m.hashCode,
        ));
  }

  StoreKeeper({Store store, this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Inventory.storeUpdater.stream,
      builder: (ctx, _) {
        var recent = Set<int>()..addAll(Mutation.recent);
        Mutation.recent.clear();
        return StoreKeeperModel(child: child, recent: recent);
      },
    );
  }
}
