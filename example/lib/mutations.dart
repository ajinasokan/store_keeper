import 'package:store_keeper/store_keeper.dart';
import 'store.dart';

class Increment extends Mutation<AppStore> {
  exec() {
    store.count++;
  }
}

class Multiply extends Mutation<AppStore> {
  final int by;

  Multiply({this.by});

  exec() {
    store.count *= by;
  }
}

class Reset extends Mutation<AppStore> {
  exec() {
    store.count = 0;
  }
}
