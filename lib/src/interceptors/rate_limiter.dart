// lib/src/interceptors/rate_limiter.dart
//
// A StoreKeeper Interceptor that rate-limits mutations. A mutation opts in by
// mixing in [RateLimit] and declaring a [RateLimit.rateLimitTime]. The first
// instance fires; any instance fired within that window of the last allowed
// one is dropped.
//
//   class Refresh extends Mutation<AppStore> with RateLimit {
//     @override
//     Duration get rateLimitTime => const Duration(seconds: 1);
//
//     @override
//     exec() => store.refresh();
//   }
//
//   runApp(StoreKeeper(
//     store: AppStore(),
//     interceptors: [RateLimiter(), MutationLogger()],
//     child: const MyApp(),
//   ));

import 'package:store_keeper/store_keeper.dart';

/// Mutations that mix in [RateLimit] are throttled by the [RateLimiter]
/// interceptor.
mixin RateLimit {
  /// Minimum spacing between two allowed firings.
  Duration get rateLimitTime;

  /// Key used to group instances in the rate limiter's map. Defaults to the
  /// mutation's runtime type; override to rate-limit per-instance.
  dynamic get rateLimitKey => runtimeType;
}

/// Drops a mutation mixing in [RateLimit] if it fires within
/// [RateLimit.rateLimitTime] of the last allowed one (per [RateLimit.rateLimitKey]).
class RateLimiter extends Interceptor {
  final _lastFired = <dynamic, DateTime>{};

  @override
  bool beforeMutation(Mutation mutation) {
    if (mutation is! RateLimit) return true;

    final rateLimit = mutation as RateLimit;
    final key = rateLimit.rateLimitKey;
    final last = _lastFired[key];
    final now = DateTime.now();

    // Inside the window since the last allowed firing: drop it.
    if (last != null && now.difference(last) < rateLimit.rateLimitTime) {
      return false;
    }

    _lastFired[key] = now;
    return true;
  }

  @override
  void afterMutation(Mutation mutation) {}
}
