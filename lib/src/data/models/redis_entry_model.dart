import 'package:dartis/src/domain/domain.dart';

class RedisEntryModel extends RedisEntry {
  const RedisEntryModel({
    required super.type,
    required super.value,
    super.expiryTime,
  });
  factory RedisEntryModel.fromEntry(RedisEntry entry) => RedisEntryModel(
    type: entry.type,
    value: entry.value,
    expiryTime: entry.expiryTime,
  );
  Map<String, dynamic> toMap() => {
    'value': value,
    'type': type,
    'expiryTime': expiryTime,
  };

  factory RedisEntryModel.fromMap(Map<String, dynamic> map) => RedisEntryModel(
    value: map['value'],
    type: RedisDataTypes.values.byName(map['type'] as String),
    expiryTime: map['expiresAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int)
        : null,
  );
}
