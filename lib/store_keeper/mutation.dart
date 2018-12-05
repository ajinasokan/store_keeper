import 'dart:async';
import 'model.dart';

typedef Mutation MutationClosure();

abstract class Mutation<T extends StoreModel> {
  static Set<Type> last = Set<Type>();

  static Map<Type, StreamController<Null>> streams = {};

  static StreamController<Null> getStreamOf(Type mutation) {
    if (!streams.containsKey(mutation))
      streams[mutation] = StreamController<Null>.broadcast();
    return streams[mutation];
  }

  T store;
  List<MutationClosure> laterMutations=[];
  Mutation() {
    store = StoreModel.instance;

    // execute mutation
    var result = exec();
    if(result is Future) {
      result.then((future_result) {
        notify();

        // and perform side effects
        if (future_result != null) {}

        notify();
        laterMutations.forEach((closure) => closure());
      });
    } else {
      notify();

      // and perform side effects
      if (result != null) {}

      notify();
      laterMutations.forEach((closure) => closure());
    }
  }

  void later(MutationClosure closure) {
    laterMutations.add(closure);
  }

  void notify() {
    // notify stream listeners
    getStreamOf(this.runtimeType).add(null);

    // notify inherited model subscribers
    last.add(this.runtimeType);
    if (StoreModel.providerKey.currentState != null)
      StoreModel.providerKey.currentState.setState(() {});
  }

  dynamic exec();
}

abstract class SideEffects<IN, OUT> {
  OUT branch(IN result);
}
