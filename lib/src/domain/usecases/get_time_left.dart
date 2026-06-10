import '../repositories/store_repository.dart';

class GetTimeLeft {
  final StoreRepository _store;
  const GetTimeLeft(this._store);

  int? call(String key) => _store.timeLeftForKey(key);
}
