import 'dart:async';
import 'package:flutter/material.dart';

part 'mutation.dart';
part 'inherited_model.dart';

/// App's store should extend this class. An instance of this class is
/// given to [StoreKeeper] while initialization.
abstract class Store {}

/// The coordinating widget that keeps track of mutations
/// and the notify the same to the listening widgets.
class StoreKeeper extends StatelessWidget {
  /// App's root widget
  final Widget child;

  /// List of all mutation interceptors
  static List<Interceptor> interceptors;

  /// This controller serves as the event broadcasting bus
  /// for the app.
  static final _events = StreamController<Type>.broadcast();

  /// Broadcast stream of mutations executing across app
  static Stream<Type> get events => _events.stream;

  /// Single store approach. This is set when initializing the app.
  static Store _store;

  /// Getter to get the current instance of [Store]. It can be
  /// casted to appropriate type by the widgets.
  static Store get store => _store;

  /// Keeps the set of mutations executed between previous and
  /// current build cycle.
  static final Set<Type> _buffer = <Type>{};

  /// Notifies widgets that mutation has executed.
  static void notify(Type mutation) {
    // Adds the mutation to the _events stream, for the
    // _StoreKeeperModel to rebuild, and to _buffer for keeping
    // track of all the mutations in the build cycle.
    _buffer.add(mutation);
    _events.add(mutation);
  }

  /// Filters the main event stream with the mutation
  /// given as parameter. This can be used to perform some callbacks inside
  /// widgets after some mutation executed.
  static Stream<Type> streamOf(Type mutation) {
    return _events.stream.where((e) => e == mutation);
  }

  /// Attaches context to the mutations given in `to` param.
  /// When a mutation specified execute widget will rebuild.
  static void listen(BuildContext context, {List<Type> to}) {
    for (var mut in to) {
      context.dependOnInheritedWidgetOfExactType<_StoreKeeperModel>(
        aspect: mut,
      );
    }
  }

  /// Constructor collects the store instance and interceptors.
  StoreKeeper({
    @required Store store,
    @required this.child,
    interceptors = const [],
  }) {
    assert(store != null, "Uninitialized store");
    assert(interceptors != null, "Interceptor list can't be null");

    StoreKeeper._store = store;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _events.stream,
      builder: (ctx, _) {
        // Copy all the mutations that executed before
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
