import 'dart:async';
import 'package:flutter/material.dart';
import 'inherited_model.dart';
import 'mutation.dart';

export 'mutation.dart';
export 'update_on.dart';

abstract class Store {
  Store() {
    StoreKeeper._store = this;
  }
}

class StoreKeeper extends StatelessWidget {
  final Widget child;

  static final _events = StreamController<int>.broadcast();

  static Stream get events => _events.stream;

  static Store _store;
  static Store get store => _store;

  static void mutate(Object key, Function(Store) mutation) {
    mutation(StoreKeeper.store);
    notify(key);
  }

  static void notify(Object mutation) {
    Mutation.recent.add(mutation.hashCode);
    _events.add(mutation.hashCode);
  }

  static Stream<int> getStreamOf(Object mutation) {
    return _events.stream.where((e) => e == mutation.hashCode);
  }

  static void update(BuildContext context, {List<Object> on}) {
    on.forEach(
      (m) => context.dependOnInheritedWidgetOfExactType<StoreKeeperModel>(
        aspect: m.hashCode,
      ),
    );
  }

  StoreKeeper({Store store, this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _events.stream,
      builder: (ctx, _) {
        var recent = Set<int>()..addAll(Mutation.recent);
        Mutation.recent.clear();
        return StoreKeeperModel(child: child, recent: recent);
      },
    );
  }
}
