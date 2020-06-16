import 'package:flutter/material.dart';
import 'dart:async';
import 'package:store_keeper/store_keeper.dart';

/// Function signature for the callback with context.
typedef void ContextCallback(BuildContext context);

/// [NotifyOn] executes the provided callbacks with context on execution
/// of the mutations. Useful to show [SnackBar] or navigate
/// to a different route after a mutation
class NotifyOn extends StatefulWidget {
  final Widget child;
  final Map<Type, ContextCallback> mutations;

  NotifyOn({
    this.child,
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
      widget.mutations[e]?.call(context);
    });
  }

  @override
  void dispose() {
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // allow null childs
    return widget.child ?? SizedBox();
  }
}
