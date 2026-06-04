import 'package:dartis/src/domain/entities/redis_entry.dart';

abstract interface class StoreRepository {
  RedisEntry? get(String key);
  bool delete(String key);
  void set(String key, RedisEntry entry);
  bool exists(String key);
  List<String> keys(String pattern);
  void setExpiryTime(String key, DateTime expiresAt);
  int? timeLeftForKey(String key);
  bool persists(String key);
  void flushData();
}
