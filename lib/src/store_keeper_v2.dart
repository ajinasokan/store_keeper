// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';

typedef MutationBuilder = Mutation Function();

abstract class Mutation<T extends Store> {
  T get store => StoreKeeper._store as T;
  final List<MutationBuilder> _laterMutations = [];
  late StackTrace _invokeTrace;

  Mutation() {
    _invokeTrace = StackTrace.current;
    _run();
  }

  void _run() async {
    for (var i in StoreKeeper._interceptors) {
      if (!i.beforeMutation(this)) return;
    }

    try {
      dynamic result = exec();
      if (result is Future) result = await result;

      StoreKeeper.notify(this);

      if (result != null && this is SideEffects) {
        dynamic out = (this as SideEffects).branch(result);
        if (out is Future) await out;
        StoreKeeper.notify(this);
      }

      for (var mut in _laterMutations) {
        mut();
      }
    } on Exception catch (e, s) {
      exception(e, s);
      StoreKeeper.notify(this);
    }

    for (var i in StoreKeeper._interceptors) {
      i.afterMutation(this);
    }
  }

  void later(MutationBuilder mutationBuilder) {
    _laterMutations.add(mutationBuilder);
  }

  dynamic exec();

  void exception(dynamic e, StackTrace s) {
    var isAssertOn = false;
    assert(isAssertOn = true);
    if (isAssertOn) {
      print(e);
      _printCleanTrace(s);
      if (!s.toString().contains("new Mutation")) {
        print("Invoked from:");
        _printCleanTrace(_invokeTrace);
      }
    }
  }

  void _printCleanTrace(StackTrace s) {
    var traces = s.toString().split("\n");
    for (var trace in traces) {
      if (trace.trim().isEmpty) continue;
      if (trace.contains("package:store_keeper/src/store_keeper_v2.dart")) {
        continue;
      }
      print(trace);
    }
  }
}

mixin SideEffects<ON> {
  dynamic branch(ON result);
}

abstract class Interceptor {
  bool beforeMutation(Mutation mutation);
  void afterMutation(Mutation mutation);
}

abstract class Store {}

class StoreKeeper extends ProxyWidget {
  final Store storeInstance;
  final List<Interceptor> interceptors;

  static late Store _store;
  static late List<Interceptor> _interceptors;

  static final StreamController<Mutation<Store>> _events =
      StreamController<Mutation>.broadcast();

  // static Store get store => _store;
  static Stream<Mutation> get events => _events.stream;

  StoreKeeper({
    Key? key,
    required this.storeInstance,
    required Widget child,
    this.interceptors = const [],
  }) : super(key: key, child: child) {
    StoreKeeper._store = storeInstance;
    StoreKeeper._interceptors = interceptors;
  }

  @override
  _StoreKeeperElement createElement() => _StoreKeeperElement(this);

  static void notify(Mutation mutation) {
    _events.add(mutation);
  }

  static Stream<Mutation> streamOf(Type mutation) {
    return _events.stream.where((e) => e.runtimeType == mutation);
  }

  static Store listen(BuildContext context, {required List<Type> to}) {
    _StoreKeeperElement? element;
    context.visitAncestorElements((ancestor) {
      if (ancestor is _StoreKeeperElement) {
        element = ancestor;
        return false;
      }
      return true;
    });
    element!.addDependency(context as Element, to);
    return element!.widget.storeInstance;
  }

  static void dispose() {
    _events.close();
  }
}

class _StoreKeeperElement extends ProxyElement {
  final Map<Element, Set<Type>> _elementSubs = {};
  final Map<Type, Set<Element>> _mutationSubs = {};

  StreamSubscription<Mutation>? _eventSubscription;

  _StoreKeeperElement(StoreKeeper widget) : super(widget);

  @override
  StoreKeeper get widget => super.widget as StoreKeeper;

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);

    _eventSubscription = StoreKeeper._events.stream.listen(_handleMutation);
  }

  @override
  void unmount() {
    _eventSubscription?.cancel();
    _elementSubs.clear();
    _mutationSubs.clear();
    super.unmount();
  }

  void addDependency(Element element, List<Type> mutations) {
    if (!mounted) return;

    _elementSubs[element] = mutations.toSet();
    for (final mutation in mutations) {
      _mutationSubs.putIfAbsent(mutation, () => {}).add(element);
    }
  }

  void _handleMutation(Mutation mutation) {
    if (!mounted) return;

    final listeners = _mutationSubs[mutation.runtimeType];
    if (listeners != null) {
      final validListeners = listeners.where((e) => e.mounted).toSet();
      _mutationSubs[mutation.runtimeType] = validListeners;

      for (final element in validListeners) {
        element.markNeedsBuild();
      }
    }

    _cleanupUnmountedElements();
  }

  void _cleanupUnmountedElements() {
    final unmountedElements =
        _elementSubs.keys.where((e) => !e.mounted).toList();
    for (final element in unmountedElements) {
      final mutations = _elementSubs.remove(element);
      if (mutations != null) {
        for (final mutation in mutations) {
          _mutationSubs[mutation]?.remove(element);
        }
      }
    }
  }

  @override
  void notifyClients(ProxyWidget oldWidget) {
    // final oldStoreKeeper = oldWidget as StoreKeeperV2;

    // if (widget.storeInstance != oldStoreKeeper.storeInstance) {
    //   StoreKeeperV2._store = widget.storeInstance;

    //   for (final listeners in _mutationSubs.values) {
    //     final validListeners = listeners.where((e) => e.mounted);
    //     for (final element in validListeners) {
    //       element.markNeedsBuild();
    //     }
    //   }
    // }

    // if (widget.interceptors != oldStoreKeeper.interceptors) {
    //   StoreKeeperV2._interceptors = widget.interceptors;
    // }
  }

  @override
  void updated(ProxyWidget oldWidget) {
    super.updated(oldWidget);
    _cleanupUnmountedElements();
  }
}
