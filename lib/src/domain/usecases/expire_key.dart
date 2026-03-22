import '../repositories/store_repository.dart';

class ExpireKey {
  final StoreRepository _store;
  const ExpireKey(this._store);

  bool call(String key, Duration duration) {
    final entry = _store.get(key);
    if (entry == null || entry.isEntryExpired) return false;
    _store.setExpiryTime(key, DateTime.now().add(duration));
    return true;
  }
}
