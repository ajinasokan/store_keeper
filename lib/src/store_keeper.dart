import 'dart:async';
import 'package:flutter/material.dart';

part 'mutation.dart';
part 'inherited_model.dart';

/// [Store] is just to avoid a dynamic reference.
/// App's store should extend this class. An instance of [Store] is
/// given to [StoreKeeper] while initialization.
abstract class Store {}

/// [StoreKeeper] is the coordinating widget that keeps track of
/// mutations and the notify the same to the [_StoreKeeperModel]
class StoreKeeper extends StatelessWidget {
  /// [child] holds app's root widget
  final Widget child;

  /// This controller serves as the event broadcasting bus
  /// for the app.
  static final _events = StreamController<Type>.broadcast();

  /// [events] is the broadcast stream of mutations happening across app
  static Stream<Type> get events => _events.stream;

  /// Single store approach. This is set when initializing the app.
  static Store _store;

  /// [store] is the getter to get the instance of [Store]. It can be
  /// casted to appropriate type by the widgets.
  static Store get store => _store;

  /// [_buffer] keeps the set of mutations happened between previous and
  /// current build cycle.
  static final Set<Type> _buffer = <Type>{};

  /// [notify] adds the mutation to the [_events] stream, for the
  /// [_StoreKeeperModel] to rebuild, and to [_buffer] for keeping
  /// track of all the mutations in the build cycle.
  static void notify(Type mutation) {
    _buffer.add(mutation);
    _events.add(mutation);
  }

  /// [streamOf] filters the main event stream with the mutation
  /// given as parameter. This can be used to perform some callbacks inside
  /// widgets after some mutation happened.
  static Stream<Type> streamOf(Type mutation) {
    return _events.stream.where((e) => e == mutation);
  }

  /// [listen] attaches context to the mutations given in `to` param.
  /// When a mutation specified happen widget will rebuild.
  static void listen(BuildContext context, {List<Type> to}) {
    for (var mut in to) {
      context.dependOnInheritedWidgetOfExactType<_StoreKeeperModel>(
        aspect: mut,
      );
    }
  }

  /// [StoreKeeper] constructor collects the store instance and
  /// keeps it inside [_store].
  StoreKeeper({
    @required Store store,
    @required this.child,
  }) {
    assert(store != null, "Uninitialized store");
    StoreKeeper._store = store;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _events.stream,
      builder: (ctx, _) {
        // Copy all the mutations that happened before
        // current build and clear that buffer
        final clone = <Type>{}..addAll(_buffer);
        _buffer.clear();

        // Rebuild inherited model with all the mutations
        // inside "clone" as the aspects changed
        return _StoreKeeperModel(child: child, recent: clone);
      },
    );
  }
}
