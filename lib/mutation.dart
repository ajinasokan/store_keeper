import 'dart:async';
import 'inventory.dart';
import 'store_keeper.dart';

typedef Mutation MutationClosure();

abstract class Mutation<T extends Store> {
  static Set<int> recent = Set<int>();

  T store;
  List<MutationClosure> laterMutations = [];

  Mutation() {
    () async {
      store = Inventory.storeHandle;

      dynamic result = exec();
      if (result is Future) result = await result;

      StoreKeeper.notify(this.runtimeType);

      if (result != null && this is SideEffects) {
        dynamic out = (this as SideEffects).branch(result);
        if (out is Future) await out;

        StoreKeeper.notify(this.runtimeType);
      }

      laterMutations.forEach((closure) => closure());
    }()
        .catchError((e, s) {
      exception(e, s);
      StoreKeeper.notify(this.runtimeType);
    });
  }

  void later(MutationClosure closure) {
    laterMutations.add(closure);
  }

  dynamic exec();

  void exception(dynamic e, StackTrace s) {
    print(e);
    print(s);
  }
}

abstract class SideEffects<ON> {
  dynamic branch(ON result);
}
