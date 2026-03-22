import '../repositories/store_repository.dart';

class DeleteKey {
  final StoreRepository _store;
  const DeleteKey(this._store);

  int call(List<String> keys) => keys.where((k) => _store.delete(k)).length;
}
