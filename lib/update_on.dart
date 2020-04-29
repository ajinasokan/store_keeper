import 'package:flutter/material.dart';
import 'dart:async';
import 'store_keeper.dart';

class UpdateOn<T> extends StatelessWidget {
  final WidgetBuilder builder;
  final List<Object> mutations;
  final Set<int> _mutCodes;

  UpdateOn({this.builder, this.mutations})
      : _mutCodes = mutations?.map((i) => i.hashCode)?.toSet() ?? {};

  @override
  Widget build(BuildContext context) {
    Stream<int> stream;
    if (mutations != null) {
      stream = StoreKeeper.events.where((e) => _mutCodes.contains(e));
    } else {
      stream = StoreKeeper.getStreamOf(T);
    }

    return StreamBuilder<int>(
      stream: stream,
      builder: (BuildContext context, _) => builder(context),
    );
  }
}
