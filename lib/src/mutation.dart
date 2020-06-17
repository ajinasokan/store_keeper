part of 'store_keeper.dart';

/// [MutationBuilder] is a function that creates an object of a mutation.
/// Used for deferred execution of other mutations using [Mutation.later].
typedef MutationBuilder = Mutation Function();

/// [Mutation] holds the logic for updating the [Store].
abstract class Mutation<T extends Store> {
  /// Reference to the current instance of [Store]
  T store;

  /// List of mutation to execute after current one.
  final List<MutationBuilder> _laterMutations = [];

  /// A mutation logic inside [exec] is executed immediately after
  /// creating an object of the mutation.
  Mutation() {
    _run();
  }

  /// [_run] executes mutation.
  void _run() async {
    try {
      store = StoreKeeper.store;

      // If the execution results in a Future then await it.
      // Useful for building an HTTP request using values from
      // some async source.
      dynamic result = exec();
      if (result is Future) result = await result;

      // Notify the widgets that execution is done
      StoreKeeper.notify(runtimeType);

      // If the result is a [SideEffects] object then pipe the
      // result to the branch function. If its result is async
      // await that. And finally notify the widgets again about
      // the end of execution.
      if (result != null && this is SideEffects) {
        dynamic out = (this as SideEffects).branch(result);
        if (out is Future) await out;

        StoreKeeper.notify(runtimeType);
      }

      // Once this is done execute all the deferred mutations
      for (var mut in _laterMutations) {
        mut();
      }
    } on Exception catch (e, s) {
      // If an execption happens in [exec] or [SideEffects] then
      // it is caught and sent to [exception] callback. This is
      // useful for showing a generic error message or crash reporting.
      exception(e, s);
      StoreKeeper.notify(runtimeType);
    }
  }

  /// [later] simply adds the mutationBuilder to the list.
  void later(MutationBuilder mutationBuilder) {
    _laterMutations.add(mutationBuilder);
  }

  /// [exec] function implements the logic of the mutation.
  /// It can return any value. If it is a [Future] it will be awaited.
  /// If it is [SideEffects] object, result will be piped to its
  /// [SideEffects.branch] call.
  dynamic exec();

  /// [execption] callback receives all the errors with their [StackTrace].
  /// If assertions are on, which usually means app is in debug mode, then
  /// both exception and stack trace is printed. This can be overridden by
  /// the mutation implementation.
  void exception(dynamic e, StackTrace s) {
    var isAssertOn = false;
    assert(isAssertOn = true);
    if (isAssertOn) {
      print(e);
      print(s);
    }
  }
}

/// [SideEffects] is a secondary mutation executed based on the
/// result of the first. For example, an http request will have a
/// success or a fail side effect after request is complete.
mixin SideEffects<ON> {
  dynamic branch(ON result);
}
