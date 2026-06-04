import 'dart:async';
import 'dart:collection';

import '../../domain/entities/redis_entry.dart';
import '../../domain/repositories/store_repository.dart';

class InMemoryStoreRepository implements StoreRepository {
  final _store = HashMap<String, RedisEntry>();

  final _timers = HashMap<String, Timer>();

  @override
  RedisEntry? get(String key) {
    final entry = _store[key];

    if (entry == null) return null;

    if (entry.isEntryExpired) {
      evict(key);
      return null;
    }

    return entry;
  }

  @override
  bool exists(String key) => get(key) != null;

  @override
  int? timeLeftForKey(String key) {
    final entry = _store[key];

    if (entry == null || entry.isEntryExpired) return null;
    if (entry.expiryTime == null) return -1;

    return entry.expiryTime!.difference(DateTime.now()).inMilliseconds;
  }

  @override
  List<String> keys(String pattern) {
    final regex = globToRegex(pattern);

    return _store.keys
        .where((key) => !_store[key]!.isEntryExpired && regex.hasMatch(key))
        .toList();
  }

  @override
  void set(String key, RedisEntry entry) {
    cancelTimer(key);

    _store[key] = entry;

    if (entry.expiryTime != null) {
      _scheduleEviction(key, entry.expiryTime!);
    }
  }

  @override
  void setExpiryTime(String key, DateTime expiryTime) {
    final entry = _store[key];
    if (entry == null) return;

    cancelTimer(key);
    _store[key] = entry.copyWith(expiryTime: expiryTime);
    _scheduleEviction(key, expiryTime);
  }

  @override
  bool persists(String key) {
    final entry = _store[key];

    if (entry == null || entry.expiryTime == null) return false;

    cancelTimer(key);
    _store[key] = entry.copyWith();
    return true;
  }

  @override
  bool delete(String key) {
    cancelTimer(key);
    return _store.remove(key) != null;
  }

  @override
  void flushData() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _store.clear();
  }

  void _scheduleEviction(String key, DateTime expiresAt) {
    final timeUntilExpiry = expiresAt.difference(DateTime.now());

    if (timeUntilExpiry.isNegative) {
      evict(key);
      return;
    }

    _timers[key] = Timer(timeUntilExpiry, () => evict(key));
  }

  void cancelTimer(String key) {
    _timers.remove(key)?.cancel();
  }

  void evict(String key) {
    _store.remove(key);
    _timers.remove(key)?.cancel();
  }

  RegExp globToRegex(String pattern) {
    final buffer = StringBuffer('^');

    for (final char in pattern.runes) {
      final c = String.fromCharCode(char);
      switch (c) {
        case '*':
          buffer.write('.*');
        case '?':
          buffer.write('.');
        case '.':
          buffer.write(r'\.');
        default:
          buffer.write(RegExp.escape(c));
      }
    }

    buffer.write(r'$');
    return RegExp(buffer.toString());
  }
}
