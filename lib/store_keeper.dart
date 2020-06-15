import 'dart:async';
import 'package:flutter/material.dart';

part 'mutation.dart';
part 'inherited_model.dart';

abstract class Store {}

class StoreKeeper extends StatelessWidget {
  final Widget child;

  static final _events = StreamController<Type>.broadcast();

  static Stream<Type> get events => _events.stream;

  static Store _store;
  static Store get store => _store;

  static Set<Type> _buffer = Set<Type>();
  static void notify(Type mutation) {
    _buffer.add(mutation);
    _events.add(mutation);
  }

  static Stream<Type> streamOf(Type mutation) {
    return _events.stream.where((e) => e == mutation);
  }

  static void listen(BuildContext context, {List<Type> to}) {
    to.forEach(
      (m) => context.dependOnInheritedWidgetOfExactType<_StoreKeeperModel>(
        aspect: m,
      ),
    );
  }

  StoreKeeper({Store store, this.child}) {
    assert(store != null, "Uninitialized store");
    StoreKeeper._store = store;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _events.stream,
      builder: (ctx, _) {
        final clone = Set<Type>()..addAll(_buffer);
        _buffer.clear();
        return _StoreKeeperModel(child: child, recent: clone);
      },
    );
  }
}
