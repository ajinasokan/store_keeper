import 'package:flutter/material.dart' show GlobalKey, State;
import 'mutation.dart' show MutationClosure;
import 'dart:async';

abstract class Store {
  Store() {
    Inventory.storeHandle = this;
  }
}

class Inventory {
  static Store storeHandle;

  static final storeUpdater = StreamController<int>.broadcast();

  static Map<int, StreamController<Null>> streams = {};
}
