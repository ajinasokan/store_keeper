// lib/src/interceptors/debounce.dart
//
// A StoreKeeper Interceptor that debounces mutations. A mutation opts in by
// mixing in [Debounce] and declaring a [Debounce.debounceTime]. The first
// instance fires immediately (leading edge); instances arriving within the
// window are declined but the latest one is kept and fired once the window
// closes (trailing edge). The trailing fire opens a new window, so under a
// sustained burst firings stay spaced by the debounce time.
//
//   class Search extends Mutation<AppStore> with Debounce {
//     final String query;
//     Search(this.query);
//
//     @override
//     Duration get debounceTime => const Duration(milliseconds: 300);
//
//     @override
//     exec() => store.query = query;
//   }
//
//   runApp(StoreKeeper(
//     store: AppStore(),
//     // Register before MutationLogger so declined instances aren't logged.
//     interceptors: [Debouncer(), MutationLogger()],
//     child: const MyApp(),
//   ));

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:store_keeper/store_keeper.dart';

/// Mutations that mix in [Debounce] are coalesced by the [Debouncer]
/// interceptor.
mixin Debounce {
  /// The window duration: minimum spacing between two firings.
  Duration get debounceTime;

  /// Key used to group instances in the debouncer's maps. Defaults to the
  /// mutation's runtime type; override to debounce per-instance.
  dynamic get debounceKey => runtimeType;
}

/// Coalesces bursts of a mutation that mixes in [Debounce].
///
/// - First instance passes and opens a window of [Debounce.debounceTime].
/// - Instances inside the window are declined; the latest one is kept
///   (newer overwrites older).
/// - When the window closes, the kept instance is fired and opens a new
///   window (it becomes the next leading edge). If nothing is pending the
///   key goes idle.
class Debouncer extends Interceptor {
  final _timers = <dynamic, Timer>{};
  final _pending = <dynamic, Mutation>{};
  final _passthrough = <Mutation>{};

  /// Whether to log blocked and debounced-fire mutations. Defaults to
  /// [kDebugMode].
  final bool verbose;

  Debouncer({this.verbose = kDebugMode});

  @override
  bool beforeMutation(Mutation mutation) {
    if (mutation is! Debounce) return true;

    // A deferred instance being replayed after its window closed: let it
    // through and open a fresh window (new leading edge).
    if (_passthrough.remove(mutation)) {
      _openWindow(mutation);
      return true;
    }

    final key = (mutation as Debounce).debounceKey;

    // No open window: leading edge. Pass and start the window.
    if (!_timers.containsKey(key)) {
      _openWindow(mutation);
      return true;
    }

    // Inside the window: decline and remember the latest instance.
    if (verbose) {
      developer.log(
        '${mutation.runtimeType} blocked',
        name: 'Debouncer',
      );
    }
    _pending[key] = mutation;
    return false;
  }

  void _openWindow(Mutation mutation) {
    final debounce = mutation as Debounce;
    final key = debounce.debounceKey;
    _timers[key] = Timer(debounce.debounceTime, () {
      _timers.remove(key);
      final pending = _pending.remove(key);
      if (pending != null) {
        if (verbose) {
          developer.log(
            '${pending.runtimeType} released',
            name: 'Debouncer',
          );
        }
        _passthrough.add(pending);
        pending.redispatch();
      }
    });
  }

  @override
  void afterMutation(Mutation mutation) {}
}
