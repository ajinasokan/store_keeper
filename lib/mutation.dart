import 'dart:async';
import 'inventory.dart';
import 'store_keeper.dart';

typedef Mutation MutationClosure();

abstract class Mutation<T extends Store> {
  static Set<int> recent = Set<int>();

  T store;
  List<MutationClosure> laterMutations = [];

  Mutation() {
    store = Inventory.storeHandle;

    // execute mutation
    var result = exec();
    if (result is Future) {
      result.then((futureResult) {
        StoreKeeper.notify(this.runtimeType);

        // and perform side effects
        if (futureResult != null) {
          if (this is SideEffects) (this as SideEffects).branch(result);
        }

        StoreKeeper.notify(this.runtimeType);
        laterMutations.forEach((closure) => closure());
      });
    } else {
      StoreKeeper.notify(this.runtimeType);

      // and perform side effects
      if (result != null) {
        if (this is SideEffects) (this as SideEffects).branch(result);
      }

      StoreKeeper.notify(this.runtimeType);
      laterMutations.forEach((closure) => closure());
    }
  }

  void later(MutationClosure closure) {
    laterMutations.add(closure);
  }

  dynamic exec();
}

abstract class SideEffects<IN, OUT> {
  OUT branch(IN result);
}
