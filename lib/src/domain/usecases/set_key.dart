import 'package:dartis/src/domain/entities/redis_data_types.dart';

import '../entities/redis_entry.dart';
import '../repositories/store_repository.dart';

class SetKey {
  final StoreRepository _store;
  const SetKey(this._store);

  void call(
    String key,
    String value, {
    Duration? expiry,
    bool nx = false,
    bool xx = false,
  }) {
    final existing = _store.get(key);

    if (nx && existing != null && !existing.isEntryExpired) return;
    if (xx && (existing == null || existing.isEntryExpired)) return;

    final expiresAt = expiry != null ? DateTime.now().add(expiry) : null;

    _store.set(
      key,
      RedisEntry(
        value: value,
        type: RedisDataTypes.string,
        expiryTime: expiresAt,
      ),
    );
  }
}
