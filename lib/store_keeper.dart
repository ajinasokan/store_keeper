import 'dart:async';
import 'package:async/async.dart' show StreamGroup;
import 'package:flutter/material.dart';

abstract class Model {}

abstract class StoreModel {
  static GlobalKey<_StoreKeeperProviderState> providerKey = GlobalKey();

  static StoreModel instance;

  StoreModel() {
    instance = this;
  }
}

abstract class Mutation<T extends StoreModel> {
  static Type last;
  T store;
  Mutation() {
    store = StoreModel.instance;
    exec();
    _getStreamOf(this.runtimeType).add(null);
    last = this.runtimeType;
    if (StoreModel.providerKey.currentState != null)
      StoreModel.providerKey.currentState.setState(() {});
  }
  void exec();
}

Map<Type, StreamController<Null>> _streams = {};

StreamController<Null> _getStreamOf(Type mutation) {
  if (!_streams.containsKey(mutation))
    _streams[mutation] = StreamController<Null>.broadcast();
  return _streams[mutation];
}

class UpdateOn<T extends Mutation> extends StatelessWidget {
  final WidgetBuilder builder;
  final List<Type> mutations;

  UpdateOn({this.builder, this.mutations});

  @override
  Widget build(BuildContext context) {
    Stream<Null> stream = mutations != null
        ? StreamGroup.merge(mutations.map((m) => _getStreamOf(m).stream))
        : _getStreamOf(T).stream;

    return StreamBuilder<Null>(
      stream: stream,
      builder: (BuildContext context, _) => builder(context),
    );
  }
}

class _StoreKeeperData {
  final BuildContext context;

  _StoreKeeperData({this.context});

  T getStore<T extends StoreModel>() => StoreModel.instance as T;

  void notifyOn(List<Type> mutations) {
    mutations.forEach((m) {
      context.inheritFromWidgetOfExactType(StoreKeeper, aspect: m);
    });
  }
}

class StoreKeeper extends InheritedModel<Type> {
  StoreKeeper({Widget child}) : super(child: child);

  static _StoreKeeperData of(BuildContext context) {
    return _StoreKeeperData(context: context);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  @override
  bool updateShouldNotifyDependent(_, Set<Type> deps) =>
      deps.contains(Mutation.last);
}

class StoreKeeperProvider<T extends StoreModel> extends StatefulWidget {
  final Widget child;
  final T store;

  StoreKeeperProvider({this.child, this.store})
      : super(key: StoreModel.providerKey);

  @override
  _StoreKeeperProviderState createState() => _StoreKeeperProviderState();
}

class _StoreKeeperProviderState extends State<StoreKeeperProvider> {
  @override
  Widget build(BuildContext context) {
    return StoreKeeper(child: widget.child);
  }
}
