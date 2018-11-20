import 'package:flutter/material.dart' show GlobalKey, State;

abstract class Model {}

abstract class StoreModel {
  static GlobalKey<State> providerKey = GlobalKey();

  static StoreModel instance;

  StoreModel() {
    instance = this;
  }
}
