import 'store_keeper.dart';
import 'store.dart';

class IncrementA extends Mutation<Store> {
  void exec() {
    store.counterA++;
  }
}

class IncrementB extends Mutation<Store> {
  void exec() {
    store.counterB++;
  }
}
