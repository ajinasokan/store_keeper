# StoreKeeper Improvements TODO

## Critical Issues (High Priority)

### 1. Memory Leaks
- [ ] Add disposal mechanism for `StreamController` in `lib/src/store_keeper.dart:22`
- [ ] Implement `dispose()` method to close streams and clear static references
- [ ] Add lifecycle management for long-running applications

### 2. Race Conditions
- [ ] Fix buffer clearing atomicity in `lib/src/store_keeper.dart:83`
- [ ] Add synchronization for concurrent mutations
- [ ] Implement thread-safe access to shared state

## Medium Priority Issues

### 3. Error Handling
- [ ] Prevent `notify()` calls on exceptions in `lib/src/mutation.dart:61`
- [ ] Add differentiation between recoverable/non-recoverable errors
- [ ] Implement error state management

### 4. Late Initialization Safety
- [ ] Add null safety guards for `_store` and `_interceptors`
- [ ] Implement proper initialization checks
- [ ] Add runtime error prevention for late variables

## Proposed Solutions

### Memory Management
```dart
static void dispose() {
  _events.close();
  _buffer.clear();
}
```

### Thread Safety
```dart
static final _bufferLock = Object();
// Use synchronized access to _buffer
```

### Error States
```dart
abstract class Mutation<T extends Store> {
  bool get shouldNotifyOnError => false;
}
```

## Additional Considerations
- [ ] Add comprehensive unit tests for concurrent scenarios
- [ ] Consider implementing mutation queuing for better predictability
- [ ] Add debugging tools for mutation flow visualization
- [ ] Document best practices for mutation design


```dart
StoreKeeper.of(context).store

StoreKeeper.of(context).depend(<Type>[]);
StoreKeeper.of(context).subscribe(<Type>[]);

StoreKeeper.of(context).listen(to: Type, callback: VoidCallback)
StoreKeeper.of(context).exec(mutation)

// one function for listen and notifyon
StoreKeeper.of(context).listen(
  to: <Type>[],
  callbacks: <Type, MutationCallback>{},
)

// 
Mutation.notify()
Mutation.state => created, running, success, fail
```