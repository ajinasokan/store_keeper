import 'dart:async';
import 'dart:developer' as developer;

import '../../store_keeper.dart';

/// A StoreKeeper [Interceptor] that persists the store after certain mutations.
/// Pass the set of mutation types that should trigger a save via [persistOn],
/// and a [save] callback that writes the store somewhere (e.g. the keyval
/// table). Saves are debounced: a burst of matching mutations collapses into a
/// single save once [debounce] of quiet time passes, so we don't write on every
/// mutation.
///
///   runApp(StoreKeeper(
///     store: AppStore(),
///     interceptors: [
///       StorePersister(
///         persistOn: {Login, Logout, SetTheme, AddTodo, ToggleTodo},
///         save: () async {
///           final store = StoreKeeper.store as AppStore;
///           await db.execute(
///             "INSERT OR REPLACE INTO keyval (key, value) VALUES ('app_store', ?)",
///             [store.toJson()],
///           );
///         },
///       ),
///     ],
///     child: const MyApp(),
///   ));
class StorePersister extends Interceptor {
  /// Mutation types after which the store should be persisted.
  final Set<Type> persistOn;

  /// Writes the store. Called at most once per quiet [debounce] window.
  final Future<void> Function() save;

  /// How long to wait after the last matching mutation before saving.
  final Duration debounce;

  Timer? _timer;

  StorePersister({
    required this.persistOn,
    required this.save,
    this.debounce = const Duration(seconds: 1),
  });

  @override
  bool beforeMutation(Mutation mutation) => true;

  @override
  void afterMutation(Mutation mutation) {
    if (!persistOn.contains(mutation.runtimeType)) return;

    // Restart the timer on each matching mutation so a burst results in one
    // save after things settle.
    _timer?.cancel();
    _timer = Timer(debounce, () async {
      developer.log('saving store', name: 'store_persister');
      await save();
    });
  }
}
