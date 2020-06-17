import 'package:flutter/widgets.dart';
import '../store_keeper.dart';

/// A stream builder like widget that accepts
/// mutations and rebuilds after their execution.
class BuildOn extends StatelessWidget {
  /// [builder] provides the child widget to rendered.
  final WidgetBuilder builder;

  /// Widget will rerender every time any of [mutations] executes.
  final Set<Type> mutations;

  /// Creates widget to rerender child widgets when given
  /// [mutations] execute.
  BuildOn({
    @required this.builder,
    @required this.mutations,
  }) : assert(mutations != null);

  @override
  Widget build(BuildContext context) {
    final stream = StoreKeeper.events.where(mutations.contains);
    return StreamBuilder<Type>(
      stream: stream,
      builder: (context, _) => builder(context),
    );
  }
}
