import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:store_keeper/store_keeper.dart';

import 'package:flutter/widgets.dart';

class TestStore extends Store {
  int count = 0;
  String value = "";
}

class Increment extends Mutation<TestStore> {
  @override
  void exec() {
    store.count++;
  }
}

class IncrementBy extends Mutation<TestStore> {
  int by;

  IncrementBy({this.by = 1});

  @override
  void exec() {
    store.count += by;
  }
}

class AsyncIncrement extends Mutation<TestStore> {
  final Completer comp = Completer();

  @override
  void exec() async {
    await Future.delayed(Duration(milliseconds: 10));
    store.count++;
    comp.complete();
  }
}

class IncrementLater extends Mutation<TestStore> {
  @override
  void exec() {
    later(() => Increment());
    later(() => Increment());
  }
}

class ExceptionMut extends Mutation<TestStore> {
  bool caught = false;

  @override
  void exec() {
    throw Exception();
  }

  @override
  void exception(dynamic e, StackTrace s) {
    caught = true;
  }
}

class MutationCounter extends Interceptor {
  int finished = 0;

  @override
  bool beforeMutation(Mutation<Store> mutation) {
    return true;
  }

  @override
  void afterMutation(Mutation<Store> mutation) {
    finished++;
  }
}

class SetValue extends Mutation<TestStore> with Debounce {
  final String value;

  SetValue(this.value);

  @override
  Duration get debounceTime => const Duration(milliseconds: 30);

  @override
  void exec() {
    store.value = value;
  }
}

class SetKeyedValue extends Mutation<TestStore> with Debounce {
  final String key;
  final String value;

  SetKeyedValue(this.key, this.value);

  @override
  Duration get debounceTime => const Duration(milliseconds: 30);

  @override
  dynamic get debounceKey => key;

  @override
  void exec() {
    store.value = "$key:$value";
  }
}

class MutationRejector extends Interceptor {
  int rejected = 0;

  @override
  bool beforeMutation(Mutation<Store> mutation) {
    if (mutation is Increment) {
      rejected++;
      return false;
    }
    return true;
  }

  @override
  void afterMutation(Mutation<Store> mutation) {}
}

void main() {
  group("event management", () {
    test('incrementing count', () {
      StoreKeeper(store: TestStore(), child: SizedBox());
      final store = StoreKeeper.store as TestStore;

      expect(store.count, 0);
      Increment();
      expect(store.count, 1);
    });

    test('stream of events', () {
      StoreKeeper(store: TestStore(), child: SizedBox());

      final stream = StoreKeeper.events;
      expectLater(stream.first, completion(isA<Increment>()));
      Increment();
    });

    test('stream of mutation events', () {
      StoreKeeper(store: TestStore(), child: SizedBox());

      final stream = StoreKeeper.streamOf(Increment);
      expectLater(stream.first, completion(isA<Increment>()));
      Increment();
    });

    test('exception catching', () {
      StoreKeeper(store: TestStore(), child: SizedBox());

      final em = ExceptionMut();
      expect(em.caught, true);
    });

    test('lazy execution', () {
      StoreKeeper(store: TestStore(), child: SizedBox());
      final store = StoreKeeper.store as TestStore;

      IncrementLater();
      expect(store.count, 2);
    });

    test('async execution', () async {
      StoreKeeper(store: TestStore(), child: SizedBox());
      final store = StoreKeeper.store as TestStore;

      final mut = AsyncIncrement();
      expect(store.count, 0);
      await mut.comp.future;
      expect(store.count, 1);
    });

    test('interceptor execution', () async {
      final mutCount = MutationCounter();
      StoreKeeper(
        store: TestStore(),
        interceptors: [mutCount],
        child: SizedBox(),
      );

      expect(mutCount.finished, 0);
      Increment();
      expect(mutCount.finished, 1);
    });

    test('interceptor rejection', () async {
      final mutReject = MutationRejector();
      StoreKeeper(
        store: TestStore(),
        interceptors: [mutReject],
        child: SizedBox(),
      );
      final store = StoreKeeper.store as TestStore;

      expect(mutReject.rejected, 0);
      expect(store.count, 0);
      Increment();
      IncrementBy(by: 5);
      expect(mutReject.rejected, 1);
      expect(store.count, 5);
    });
  });

  group("debounce interceptor", () {
    test('leading fires, burst coalesces to latest', () async {
      StoreKeeper(
        store: TestStore(),
        interceptors: [Debouncer()],
        child: SizedBox(),
      );
      final store = StoreKeeper.store as TestStore;

      // First instance fires immediately (leading edge).
      SetValue("a");
      expect(store.value, "a");

      // Inside the window: declined, latest kept (b overwritten by c).
      SetValue("b");
      SetValue("c");
      expect(store.value, "a");

      // After the window closes only the latest (c) lands.
      await Future.delayed(const Duration(milliseconds: 50));
      expect(store.value, "c");
    });

    test('trailing fire opens a new window', () async {
      StoreKeeper(
        store: TestStore(),
        interceptors: [Debouncer()],
        child: SizedBox(),
      );
      final store = StoreKeeper.store as TestStore;

      SetValue("a"); // leading
      SetValue("b"); // deferred
      await Future.delayed(const Duration(milliseconds: 50));
      expect(store.value, "b"); // trailing fire of b opens a new window

      // An instance right after the trailing fire is inside the new window,
      // so it is deferred rather than firing immediately.
      SetValue("c");
      expect(store.value, "b");
      await Future.delayed(const Duration(milliseconds: 50));
      expect(store.value, "c");
    });

    test('different keys debounce independently', () async {
      StoreKeeper(
        store: TestStore(),
        interceptors: [Debouncer()],
        child: SizedBox(),
      );
      final store = StoreKeeper.store as TestStore;

      // Different keys => independent leading edges, both fire immediately.
      SetKeyedValue("x", "1");
      expect(store.value, "x:1");
      SetKeyedValue("y", "1");
      expect(store.value, "y:1");

      // Same key within window is deferred to latest.
      SetKeyedValue("x", "2");
      SetKeyedValue("x", "3");
      await Future.delayed(const Duration(milliseconds: 50));
      expect(store.value, "x:3");
    });
  });
}
