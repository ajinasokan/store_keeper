import 'package:flutter/material.dart';
import 'dart:async';
import 'package:store_keeper/store_keeper.dart';

class NotifyOn extends StatefulWidget {
  final Widget child;
  final Map<Type, VoidCallback> mutations;

  NotifyOn({
    @required this.child,
    @required this.mutations,
  }) : assert(mutations != null);

  @override
  _NotifyOnState createState() => _NotifyOnState();
}

class _NotifyOnState extends State<NotifyOn> {
  StreamSubscription eventSub;

  @override
  void initState() {
    super.initState();
    final mutations = widget.mutations.keys.toSet();
    final stream = StoreKeeper.events.where((e) => mutations.contains(e));
    eventSub = stream.listen((e) {
      widget.mutations[e]?.call();
    });
  }

  @override
  void dispose() {
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
