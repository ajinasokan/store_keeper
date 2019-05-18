import 'package:flutter/material.dart';
import 'package:async/async.dart' show StreamGroup;
import 'store_keeper.dart';

class UpdateOn<T> extends StatelessWidget {
  final WidgetBuilder builder;
  final List<Object> mutations;

  UpdateOn({this.builder, this.mutations});

  @override
  Widget build(BuildContext context) {
    Stream<Null> stream = mutations != null
        ? StreamGroup.merge(
            mutations.map((m) => StoreKeeper.getStreamOf(m.hashCode).stream))
        : StoreKeeper.getStreamOf(T.hashCode).stream;

    return StreamBuilder<Null>(
      stream: stream,
      builder: (BuildContext context, _) => builder(context),
    );
  }
}
