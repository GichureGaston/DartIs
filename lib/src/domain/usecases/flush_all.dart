import '../repositories/store_repository.dart';

class FlushAll {
  final StoreRepository _store;
  const FlushAll(this._store);

  void call() => _store.flushData();
}
