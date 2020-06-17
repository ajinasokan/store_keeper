part of 'store_keeper.dart';

/// Function signature for mutations that has deferred execution.
/// [Mutation.later] accepts functions with this signature.
typedef MutationBuilder = Mutation Function();

/// An implementation of this class holds the logic for updating the [Store].
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
    // Execute all the interceptors. If returns false cancel mutation.
    for (var i in StoreKeeper.interceptors) {
      if (!i.beforeMutation(this)) return;
    }

    try {
      store = StoreKeeper.store;

      // If the execution results in a Future then await it.
      // Useful for building an HTTP request using values from
      // some async source.
      dynamic result = exec();
      if (result is Future) result = await result;

      // Notify the widgets that execution is done
      StoreKeeper.notify(runtimeType);

      // If the result is a SideEffects object then pipe the
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
      // If an execption happens in exec or SideEffects then
      // it is caught and sent to exception callback. This is
      // useful for showing a generic error message or crash reporting.
      exception(e, s);
      StoreKeeper.notify(runtimeType);
    }

    // Execute all the interceptors.
    for (var i in StoreKeeper.interceptors) {
      i.afterMutation(this);
    }
  }

  /// Adds the mutationBuilder to the list.
  void later(MutationBuilder mutationBuilder) {
    _laterMutations.add(mutationBuilder);
  }

  /// This function implements the logic of the mutation.
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

/// Secondary mutation executed based on the result of the first.
/// Similar to chaining actions in Redux. For example, an http request
/// will have a success or a fail side effect after request is complete.
mixin SideEffects<ON> {
  dynamic branch(ON result);
}

/// Implementation of this class can be used to act before or after
/// a mutation execution
abstract class Interceptor {
  /// Function called before mutation is executed.
  /// Execution can be cancelled by returning false.
  bool beforeMutation(Mutation mutation);

  /// Function called after mutation and its side effects are executed.
  void afterMutation(Mutation mutation);
}
