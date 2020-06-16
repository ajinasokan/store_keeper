part of 'store_keeper.dart';

/// [_StoreKeeperModel] tracks the listener widgets and notify them when
/// their corresponding mutation executes
class _StoreKeeperModel extends InheritedModel<Type> {
  final Set<Type> recent;

  _StoreKeeperModel({Widget child, this.recent}) : super(child: child);

  @override
  bool updateShouldNotify(_) => true;

  @override
  bool updateShouldNotifyDependent(_, Set<Type> deps) {
    // check if there is an event happened for which
    // dependent was subscribed
    return deps.intersection(recent).isNotEmpty;
  }
}
