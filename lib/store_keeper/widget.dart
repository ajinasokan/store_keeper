import 'package:flutter/material.dart';
import 'package:async/async.dart' show StreamGroup;

import 'mutation.dart';
import 'model.dart';

class UpdateOn<T extends Mutation> extends StatelessWidget {
  final WidgetBuilder builder;
  final List<Type> mutations;

  UpdateOn({this.builder, this.mutations});

  @override
  Widget build(BuildContext context) {
    Stream<Null> stream = mutations != null
        ? StreamGroup.merge(
            mutations.map((m) => Mutation.getStreamOf(m).stream))
        : Mutation.getStreamOf(T).stream;

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
      deps.intersection(Mutation.last).length > 0;
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
