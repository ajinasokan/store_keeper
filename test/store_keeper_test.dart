import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:store_keeper/store_keeper.dart';

class TestStore extends Store {
  int count = 0;
}

class Increment extends Mutation<TestStore> {
  @override
  void exec() {
    store.count++;
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

void main() {
  group("event management", () {
    test('incrementing count', () {
      StoreKeeper(store: TestStore(), child: null);
      final store = StoreKeeper.store as TestStore;

      expect(store.count, 0);
      Increment();
      expect(store.count, 1);
    });

    test('stream of events', () {
      StoreKeeper(store: TestStore(), child: null);

      final stream = StoreKeeper.events;
      expectLater(stream.first, completion(equals(Increment)));
      Increment();
    });

    test('stream of mutation events', () {
      StoreKeeper(store: TestStore(), child: null);

      final stream = StoreKeeper.streamOf(Increment);
      expectLater(stream.first, completion(equals(Increment)));
      Increment();
    });

    test('exception catching', () {
      StoreKeeper(store: TestStore(), child: null);

      final em = ExceptionMut();
      expect(em.caught, true);
    });

    test('lazy execution', () {
      StoreKeeper(store: TestStore(), child: null);
      final store = StoreKeeper.store as TestStore;

      IncrementLater();
      expect(store.count, 2);
    });

    test('async execution', () async {
      StoreKeeper(store: TestStore(), child: null);
      final store = StoreKeeper.store as TestStore;

      final mut = AsyncIncrement();
      expect(store.count, 0);
      await mut.comp.future;
      expect(store.count, 1);
    });
  });
}
