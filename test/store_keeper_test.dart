import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:store_keeper/store_keeper.dart';

import 'package:flutter/widgets.dart';

class TestStore extends Store {
  int count = 0;
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
        child: SizedBox(),
        interceptors: [mutCount],
      );

      expect(mutCount.finished, 0);
      Increment();
      expect(mutCount.finished, 1);
    });

    test('interceptor rejection', () async {
      final mutReject = MutationRejector();
      StoreKeeper(
        store: TestStore(),
        child: SizedBox(),
        interceptors: [mutReject],
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
}
