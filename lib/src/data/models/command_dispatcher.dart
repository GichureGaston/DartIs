import 'dart:typed_data';

import '../../domain/domain.dart';
import 'resp_codec.dart';

class CommandDispatcher {
  final StoreRepository _store;
  late final SetKey _set;
  late final GetKey _get;
  late final DeleteKey _delete;
  late final ExpireKey _expire;
  late final ListKeys _listKeys;

  CommandDispatcher({required StoreRepository store}) : _store = store {
    _set = SetKey(store);
    _get = GetKey(store);
    _delete = DeleteKey(store);
    _expire = ExpireKey(store);
    _listKeys = ListKeys(store);
  }

  Uint8List dispatch(List<String> command) {
    if (command.isEmpty) return RespCodec.encodeError('empty command');

    final cmd = command[0].toUpperCase();
    final args = command.sublist(1);

    return switch (cmd) {
      'PING' => _ping(args),
      'ECHO' => _echo(args),
      'SET' => _setCmd(args),
      'GET' => _getCmd(args),
      'DEL' => _delCmd(args),
      'EXISTS' => _existsCmd(args),
      'EXPIRE' => _expireCmd(args),
      'PEXPIRE' => _pexpireCmd(args),
      'TTL' => _ttlCmd(args),
      'PTTL' => _pttlCmd(args),
      'PERSIST' => _persistCmd(args),
      'KEYS' => _keysCmd(args),
      'FLUSHALL' => _flushCmd(),
      _ => RespCodec.encodeError('unknown command `$cmd`'),
    };
  }

  Uint8List _ping(List<String> args) =>
      args.isEmpty ? RespCodec.pong : RespCodec.encodeBulkString(args[0]);

  Uint8List _echo(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for ECHO');
    }
    return RespCodec.encodeBulkString(args[0]);
  }

  Uint8List _setCmd(List<String> args) {
    if (args.length < 2) {
      return RespCodec.encodeError('wrong number of arguments for SET');
    }

    Duration? expiry;
    bool nx = false;
    bool xx = false;

    var i = 2;
    while (i < args.length) {
      switch (args[i].toUpperCase()) {
        case 'EX':
          if (i + 1 >= args.length) {
            return RespCodec.encodeError('EX requires a value');
          }
          expiry = Duration(seconds: int.parse(args[i + 1]));
          i += 2;
        case 'PX':
          if (i + 1 >= args.length) {
            return RespCodec.encodeError('PX requires a value');
          }
          expiry = Duration(milliseconds: int.parse(args[i + 1]));
          i += 2;
        case 'NX':
          nx = true;
          i++;
        case 'XX':
          xx = true;
          i++;
        default:
          i++;
      }
    }

    _set(args[0], args[1], expiry: expiry, nx: nx, xx: xx);
    return RespCodec.ok;
  }

  Uint8List _getCmd(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for GET');
    }
    return RespCodec.encodeBulkString(_get(args[0]));
  }

  Uint8List _delCmd(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for DEL');
    }
    return RespCodec.encodeInteger(_delete(args));
  }

  Uint8List _existsCmd(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for EXISTS');
    }
    final count = args.where((k) => _store.exists(k)).length;
    return RespCodec.encodeInteger(count);
  }

  Uint8List _expireCmd(List<String> args) {
    if (args.length < 2) {
      return RespCodec.encodeError('wrong number of arguments for EXPIRE');
    }
    final ok = _expire(args[0], Duration(seconds: int.parse(args[1])));
    return RespCodec.encodeInteger(ok ? 1 : 0);
  }

  Uint8List _pexpireCmd(List<String> args) {
    if (args.length < 2) {
      return RespCodec.encodeError('wrong number of arguments for PEXPIRE');
    }
    final ok = _expire(args[0], Duration(milliseconds: int.parse(args[1])));
    return RespCodec.encodeInteger(ok ? 1 : 0);
  }

  Uint8List _ttlCmd(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for TTL');
    }
    final ms = _store.timeLeftForKey(args[0]);
    if (ms == null) return RespCodec.encodeInteger(-2);
    if (ms == -1) return RespCodec.encodeInteger(-1);
    return RespCodec.encodeInteger((ms / 1000).ceil());
  }

  Uint8List _pttlCmd(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for PTTL');
    }
    final ms = _store.timeLeftForKey(args[0]);
    if (ms == null) return RespCodec.encodeInteger(-2);
    return RespCodec.encodeInteger(ms);
  }

  Uint8List _persistCmd(List<String> args) {
    if (args.isEmpty) {
      return RespCodec.encodeError('wrong number of arguments for PERSIST');
    }
    return RespCodec.encodeInteger(_store.persists(args[0]) ? 1 : 0);
  }

  Uint8List _keysCmd(List<String> args) {
    final pattern = args.isEmpty ? '*' : args[0];
    return RespCodec.encodeArray(_listKeys(pattern));
  }

  Uint8List _flushCmd() {
    _store.flushData();
    return RespCodec.ok;
  }
}
