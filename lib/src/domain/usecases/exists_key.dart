import '../repositories/store_repository.dart';

class ExistsKey {
  final StoreRepository _store;
  const ExistsKey(this._store);

  int call(List<String> keys) => keys.where((k) => _store.exists(k)).length;
}
