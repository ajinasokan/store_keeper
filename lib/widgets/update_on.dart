import 'package:flutter/widgets.dart';
import 'package:store_keeper/store_keeper.dart';

class RebuildOn extends StatelessWidget {
  final WidgetBuilder builder;
  final Set<Type> mutations;

  RebuildOn({
    @required this.builder,
    @required this.mutations,
  }) : assert(mutations != null);

  @override
  Widget build(BuildContext context) {
    final stream = StoreKeeper.events.where((e) => mutations.contains(e));
    return StreamBuilder<Type>(
      stream: stream,
      builder: (BuildContext context, _) => builder(context),
    );
  }
}
