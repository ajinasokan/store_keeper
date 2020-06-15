import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:store_keeper/store_keeper.dart';

class TestStore extends Store {
  int count = 0;
}

class Increment extends Mutation<TestStore> {
  @override
  exec() {
    store.count++;
  }
}

class AsyncIncrement extends Mutation<TestStore> {
  final comp = Completer();

  @override
  exec() async {
    await Future.delayed(Duration(milliseconds: 10));
    store.count++;
    comp.complete();
  }
}

class IncrementLater extends Mutation<TestStore> {
  @override
  exec() {
    later(() => Increment());
    later(() => Increment());
  }
}

class ExceptionMut extends Mutation<TestStore> {
  bool caught = false;

  @override
  exec() {
    throw Exception();
  }

  @override
  void exception(e, StackTrace s) {
    caught = true;
  }
}

void main() {
  group("event management", () {
    test('incrementing count', () {
      final store = TestStore();
      expect(store.count, 0);
      Increment();
      expect(store.count, 1);
    });

    test('stream of events', () {
      final store = TestStore();
      final stream = StoreKeeper.events;
      expectLater(stream.first, completion(equals((Increment).hashCode)));
      Increment();
    });

    test('stream of mutation events', () {
      final store = TestStore();
      final stream = StoreKeeper.streamOf(Increment);
      expectLater(stream.first, completion(equals((Increment).hashCode)));
      Increment();
    });

    test('exception catching', () {
      final store = TestStore();
      final em = ExceptionMut();
      expect(em.caught, true);
    });

    test('lazy execution', () {
      final store = TestStore();
      IncrementLater();
      expect(store.count, 2);
    });

    test('async execution', () async {
      final store = TestStore();
      final mut = AsyncIncrement();
      expect(store.count, 0);
      await mut.comp.future;
      expect(store.count, 1);
    });
  });
}
