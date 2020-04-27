import 'package:flutter/material.dart';
import 'dart:async';
import 'store_keeper.dart';

class UpdateOn<T> extends StatelessWidget {
  final WidgetBuilder builder;
  final List<Object> mutations;

  UpdateOn({this.builder, this.mutations});

  @override
  Widget build(BuildContext context) {
    Set<int> mutCodes = mutations.map((i) => i.hashCode).toSet();

    Stream<int> stream;
    if (mutations != null)
      stream = StoreKeeper.events.where((e) => mutCodes.contains(e));
    else
      stream = StoreKeeper.getStreamOf(T);

    return StreamBuilder<int>(
      stream: stream,
      builder: (BuildContext context, _) => builder(context),
    );
  }
}
