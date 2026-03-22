import '../repositories/store_repository.dart';

class ListKeys {
  final StoreRepository _store;
  const ListKeys(this._store);

  List<String> call(String pattern) => _store.keys(pattern);
}
