// ignore_for_file: library_private_types_in_public_api
import 'dart:async';
import 'package:flutter/material.dart';

/// Function signature for mutations that has deferred execution.
/// [Mutation.later] accepts functions with this signature.
typedef MutationBuilder = Mutation Function();

/// App's store should extend this class. An instance of this class is
/// given to [StoreKeeper] while initialization.
abstract class Store {}

/// The coordinating widget that tracks mutations and notifies listening widgets.
class StoreKeeper extends ProxyWidget {
  final List<Interceptor> interceptors;

  /// List of all mutation interceptors
  static late List<Interceptor> _interceptors;

  /// This controller serves as the event broadcasting bus for the app.
  static final _events = StreamController<Mutation<Store>>.broadcast();

  /// Broadcast stream of mutations executing across app
  static Stream<Mutation> get events => _events.stream;

  /// Single store approach. This is set when initializing the app.
  static late Store _store;

  /// Getter to get the current instance of [Store]. It can be
  /// casted to appropriate type by the widgets.
  static Store get store => _store;

  /// Notifies widgets that mutation has executed.
  static void notify(Mutation mutation) {
    // Adds the mutation to the event stream so subscribed elements
    // can mark themselves for rebuild.
    _events.add(mutation);
  }

  /// Filters the main event stream with the mutation
  /// given as parameter. This can be used to perform some callbacks inside
  /// widgets after some mutation executed.
  static Stream<Mutation> streamOf(Type mutation) {
    return _events.stream.where((e) => e.runtimeType == mutation);
  }

  /// Attaches context to the mutations given in `to` param.
  /// When a mutation specified execute widget will rebuild.
  static void listen(BuildContext context, {required List<Type> to}) {
    // Find the nearest StoreKeeper element and subscribe this calling element.
    _StoreKeeperElement? storeKeeperElement;

    context.visitAncestorElements((e) {
      if (e is _StoreKeeperElement) {
        storeKeeperElement = e;
        return false;
      }
      return true;
    });

    // The calling element is the one associated with this BuildContext.
    final callerElement = context as Element?;

    if (callerElement != null) {
      storeKeeperElement!.subscribe(callerElement, to.toSet());
    }
  }

  /// Constructor collects the store instance and interceptors.
  StoreKeeper({
    super.key,
    required Store store,
    required super.child,
    this.interceptors = const [],
  }) {
    // Initialize static state so mutations work even without pumping the widget.
    StoreKeeper._store = store;
    StoreKeeper._interceptors = interceptors;
  }

  @override
  _StoreKeeperElement createElement() => _StoreKeeperElement(this);
}

/// Custom element that manages mutation subscriptions per listening widget.
class _StoreKeeperElement extends ProxyElement {
  // Subscription to the global event stream for triggering rebuilds.
  StreamSubscription<Mutation>? eventSubscription;

  // Tracks which elements are subscribed to which mutation types.
  final elementSubs = <Element, Set<Type>>{};
  // Reverse index: which elements listen to each mutation type.
  final mutationSubs = <Type, Set<Element>>{};

  _StoreKeeperElement(super.widget);

  @override
  StoreKeeper get widget => super.widget as StoreKeeper;

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);

    // Listen to the global event stream and trigger rebuilds for subscribed elements.
    eventSubscription = StoreKeeper._events.stream.listen(handleMutation);
  }

  @override
  void unmount() {
    eventSubscription?.cancel();
    elementSubs.clear();
    mutationSubs.clear();
    super.unmount();
  }

  /// Register an element as a listener for specific mutation types.
  void subscribe(Element element, Set<Type> mutations) {
    elementSubs[element] = mutations;
    for (final mutation in mutations) {
      mutationSubs.putIfAbsent(mutation, () => {}).add(element);
    }
  }

  /// Called when a mutation fires on the global event stream.
  void handleMutation(Mutation mutation) {
    final listeners = mutationSubs[mutation.runtimeType];
    if (listeners != null) {
      // Filter to only mounted elements and mark them for rebuild.
      final validListeners = listeners.where((e) => e.mounted).toSet();
      mutationSubs[mutation.runtimeType] = validListeners;
      for (final element in validListeners) {
        element.markNeedsBuild();
      }
    }
    // Clean up unmounted elements from subscription maps.
    cleanup();
  }

  /// Remove subscriptions from elements that are no longer mounted.
  void cleanup() {
    final unmountedElements =
        elementSubs.keys.where((e) => !e.mounted).toList();
    for (final element in unmountedElements) {
      final mutations = elementSubs.remove(element);
      if (mutations != null) {
        for (final mutation in mutations) {
          mutationSubs[mutation]?.remove(element);
        }
      }
    }
  }

  @override
  void updated(ProxyWidget oldWidget) => cleanup();

  @override
  void notifyClients(covariant ProxyWidget oldWidget) {}
}

/// An implementation of this class holds the logic for updating the [Store].
abstract class Mutation<T extends Store> {
  /// Reference to the current instance of [Store]
  T get store => StoreKeeper.store as T;

  /// List of mutation to execute after current one.
  final List<MutationBuilder> _laterMutations = [];

  late StackTrace _invokeTrace;

  /// A mutation logic inside [exec] is executed immediately after
  /// creating an object of the mutation.
  Mutation() {
    _invokeTrace = StackTrace.current;
    _run();
  }

  /// [_run] executes mutation using static state (backward compatible).
  void _run() async {
    // Execute all the interceptors. If returns false cancel mutation.
    for (var i in StoreKeeper._interceptors) {
      if (!i.beforeMutation(this)) return;
    }

    try {
      // If the execution results in a Future then await it.
      dynamic result = exec();
      if (result is Future) result = await result;

      // Notify the widgets that execution is done
      StoreKeeper.notify(this);

      // If the result is a SideEffects object then pipe the
      // result to the branch function.
      if (result != null && this is SideEffects) {
        dynamic out = (this as SideEffects).branch(result);
        if (out is Future) await out;

        StoreKeeper.notify(this);
      }

      // Once this is done execute all the deferred mutations
      for (var mut in _laterMutations) {
        mut();
      }
    } on Exception catch (e, s) {
      exception(e, s);
      StoreKeeper.notify(this);
    }

    // Execute all the interceptors after mutation completes.
    for (var i in StoreKeeper._interceptors) {
      i.afterMutation(this);
    }
  }

  /// Adds the mutationBuilder to the list.
  void later(MutationBuilder mutationBuilder) {
    _laterMutations.add(mutationBuilder);
  }

  /// Re-executes this mutation through the full interceptor + notify pipeline.
  /// Used by interceptors (e.g. Debouncer) that defer a declined mutation and
  /// replay it once its window closes.
  void redispatch() => _run();

  /// This function implements the logic of the mutation.
  /// It can return any value. If it is a [Future] it will be awaited.
  /// If it is [SideEffects] object, result will be piped to its
  /// [SideEffects.branch] call.
  dynamic exec();

  /// [exception] callback receives all the errors with their [StackTrace].
  /// If assertions are on, which usually means app is in debug mode, then
  /// both exception and stack trace is printed. This can be overridden by
  /// the mutation implementation.
  void exception(dynamic e, StackTrace s) {
    var isAssertOn = false;
    assert(isAssertOn = true);
    if (isAssertOn) {
      // Intentional debug printing in assertion-only code path
      print(e); // ignore: avoid_print
      _printCleanTrace(s);
      // if there was an async suspension then construction is not
      // part of the trace. using this to detect suspensions.
      if (!s.toString().contains("new Mutation")) {
        print("Invoked from:"); // ignore: avoid_print
        _printCleanTrace(_invokeTrace);
      }
    }
  }

  void _printCleanTrace(StackTrace s) {
    var traces = s.toString().split("\n");
    for (var trace in traces) {
      if (trace.trim().isEmpty) continue;
      if (trace.contains("package:store_keeper/src/store_keeper.dart")) {
        continue;
      }

      print(trace); // ignore: avoid_print
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
/// a mutation execution.
abstract class Interceptor {
  /// Function called before mutation is executed.
  /// Execution can be cancelled by returning false.
  bool beforeMutation(Mutation mutation);

  /// Function called after mutation and its side effects are executed.
  void afterMutation(Mutation mutation);
}
