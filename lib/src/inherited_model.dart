part of 'store_keeper.dart';

/// Tracks the listener widgets and notify them when
/// their corresponding mutation executes
class _StoreKeeperModel extends InheritedModel<Type> {
  final Set<Type> recent;

  const _StoreKeeperModel({
    required super.child,
    required this.recent,
  });
  @override
  bool updateShouldNotify(_) => true;

  @override
  bool updateShouldNotifyDependent(_, Set<Type> deps) {
    // check if there is a mutation executed for which
    // dependent has listened
    return deps.intersection(recent).isNotEmpty;
  }
}
