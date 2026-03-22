import '../repositories/store_repository.dart';

class GetKey {
  final StoreRepository _store;
  const GetKey(this._store);

  String? call(String key) {
    final entry = _store.get(key);
    if (entry == null || entry.isEntryExpired) return null;
    return entry.value as String;
  }
}
