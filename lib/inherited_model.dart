import 'package:flutter/material.dart';

class StoreKeeperModel extends InheritedModel<Object> {
  final Set<int> recent;

  StoreKeeperModel({Widget child, this.recent}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  @override
  bool updateShouldNotifyDependent(_, Set<Object> deps) {
    return deps.any((d) => recent.contains(d.hashCode));
  }
}
