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

  static StreamController<Null> storeUpdater =
      StreamController<Null>.broadcast();

  static Map<int, StreamController<Null>> streams = {};
}
