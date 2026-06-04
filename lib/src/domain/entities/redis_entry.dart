import 'package:dartis/src/domain/entities/redis_data_types.dart';
import 'package:equatable/equatable.dart';

class RedisEntry extends Equatable {
  final dynamic value;
  final RedisDataTypes type;
  final DateTime? expiryTime;
  const RedisEntry({required this.value, required this.type, this.expiryTime});
  bool get isEntryExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  RedisEntry copyWith({
    dynamic value,
    RedisDataTypes? type,
    DateTime? expiryTime,
  }) {
    return RedisEntry(
      type: type ?? this.type,
      value: value ?? this.value,
      expiryTime: expiryTime ?? this.expiryTime,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [value, type, expiryTime];
}
