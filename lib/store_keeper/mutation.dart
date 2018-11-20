import 'dart:async';
import 'model.dart';

abstract class Mutation<T extends StoreModel> {
  static Type last;

  static Map<Type, StreamController<Null>> streams = {};

  static StreamController<Null> getStreamOf(Type mutation) {
    if (!streams.containsKey(mutation))
      streams[mutation] = StreamController<Null>.broadcast();
    return streams[mutation];
  }

  T store;
  Mutation() {
    store = StoreModel.instance;

    // execute mutation
    var result = exec();
    notify();

    // and perform side effects
    if (result != null) {}

    notify();
  }

  void notify() {
    // notify stream listeners
    getStreamOf(this.runtimeType).add(null);

    // notify inherited model subscribers
    last = this.runtimeType;
    if (StoreModel.providerKey.currentState != null)
      StoreModel.providerKey.currentState.setState(() {});
  }

  dynamic exec();
}

abstract class SideEffects<IN, OUT> {
  OUT branch(IN result);
}
