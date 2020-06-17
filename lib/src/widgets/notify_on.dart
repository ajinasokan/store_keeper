import 'dart:async';
import 'package:flutter/material.dart';
import '../store_keeper.dart';

/// Function signature for the callback with context.
typedef ContextCallback = void Function(BuildContext context);

/// [NotifyOn] executes the provided callbacks with context on execution
/// of the mutations. Useful to show [SnackBar] or navigate
/// to a different route after a mutation
class NotifyOn extends StatefulWidget {
  /// Optional child widget
  final Widget child;

  /// Map of mutations and their corresponding callback
  final Map<Type, ContextCallback> mutations;

  /// [NotifyOn] make callbacks for given mutations
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
    final stream = StoreKeeper.events.where(mutations.contains);
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
