import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode;

import '../../store_keeper.dart';

/// Turns a mutation into a log line. Defaults to the mutation's type name.
typedef LogFormatter = String Function(Mutation mutation);

/// Writes a formatted log line somewhere. Defaults to [developer.log].
typedef LogWriter = void Function(String line);

/// A StoreKeeper [Interceptor] that logs every mutation as it fires. Pass a set
/// of mutation types to [skip] to silence noisy mutations (e.g. high-frequency
/// ones).
///
///   runApp(StoreKeeper(
///     store: AppStore(),
///     interceptors: [MutationLogger(skip: {Tick, ScrollChanged})],
///     child: const MyApp(),
///   ));
class MutationLogger extends Interceptor {
  /// Mutation types to exclude from logging.
  final Set<Type> skip;

  /// Whether logging is active. Defaults to [kDebugMode].
  final bool enabled;

  /// Formats a mutation into a log line. Defaults to the mutation type name.
  final LogFormatter formatter;

  /// Writes the formatted line. When null, [developer.log] is used.
  final LogWriter? writer;

  MutationLogger({
    this.skip = const {},
    this.enabled = kDebugMode,
    LogFormatter? formatter,
    this.writer,
  }) : formatter = formatter ?? _defaultFormatter;

  static String _defaultFormatter(Mutation mutation) =>
      '${mutation.runtimeType}';

  @override
  bool beforeMutation(Mutation mutation) {
    if (enabled && !skip.contains(mutation.runtimeType)) {
      final line = formatter(mutation);
      if (writer != null) {
        writer!(line);
      } else {
        developer.log(line, name: 'mutation');
      }
    }
    return true;
  }

  @override
  void afterMutation(Mutation mutation) {}
}
