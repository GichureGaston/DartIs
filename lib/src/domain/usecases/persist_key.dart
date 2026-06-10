import '../repositories/store_repository.dart';

class PersistKey {
  final StoreRepository _store;
  const PersistKey(this._store);

  bool call(String key) => _store.persists(key);
}
