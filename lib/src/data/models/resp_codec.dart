import 'dart:convert';
import 'dart:typed_data';

class RespCodec {
  static const _crlf = '\r\n';

  static Uint8List encodeSimpleString(String s) => _toBytes('+$s$_crlf');

  static Uint8List encodeError(String message) =>
      _toBytes('-ERR $message$_crlf');

  static Uint8List encodeInteger(int n) => _toBytes(':$n$_crlf');

  static Uint8List encodeBulkString(String? s) {
    if (s == null) return _toBytes(r'$-1' + _crlf);
    final bytes = utf8.encode(s);
    return _toBytes('\$${bytes.length}$_crlf$s$_crlf');
  }

  static Uint8List encodeArray(List<String?> items) {
    final buffer = StringBuffer('*${items.length}$_crlf');
    for (final item in items) {
      if (item == null) {
        buffer.write(r'$-1' + _crlf);
      } else {
        final bytes = utf8.encode(item);
        buffer.write('\$${bytes.length}$_crlf$item$_crlf');
      }
    }
    return _toBytes(buffer.toString());
  }

  static final ok = encodeSimpleString('OK');
  static final pong = encodeSimpleString('PONG');
  static final nullBulk = encodeBulkString(null);
  static final zero = encodeInteger(0);
  static final one = encodeInteger(1);

  static (List<List<String>>, Uint8List) decode(Uint8List buffer) {
    final commands = <List<String>>[];
    var offset = 0;

    while (offset < buffer.length) {
      final result = _parseValue(buffer, offset);
      if (result == null) break;
      final (value, newOffset) = result;
      if (value is List) {
        commands.add(value.cast<String>());
      }
      offset = newOffset;
    }

    return (commands, buffer.sublist(offset));
  }

  static (dynamic, int)? _parseValue(Uint8List buf, int offset) {
    if (offset >= buf.length) return null;
    final typeByte = String.fromCharCode(buf[offset]);

    return switch (typeByte) {
      '*' => _parseArray(buf, offset),
      r'$' => _parseBulkString(buf, offset),
      '+' => _parseSimpleString(buf, offset),
      '-' => _parseSimpleString(buf, offset),
      ':' => _parseInteger(buf, offset),
      _ => null,
    };
  }

  static (String, int)? _parseSimpleString(Uint8List buf, int offset) {
    final lineEnd = _findCrlf(buf, offset + 1);
    if (lineEnd == -1) return null;
    final value = utf8.decode(buf.sublist(offset + 1, lineEnd));
    return (value, lineEnd + 2);
  }

  static (int, int)? _parseInteger(Uint8List buf, int offset) {
    final lineEnd = _findCrlf(buf, offset + 1);
    if (lineEnd == -1) return null;
    final value = int.parse(utf8.decode(buf.sublist(offset + 1, lineEnd)));
    return (value, lineEnd + 2);
  }

  static (String?, int)? _parseBulkString(Uint8List buf, int offset) {
    final lengthLineEnd = _findCrlf(buf, offset + 1);
    if (lengthLineEnd == -1) return null;
    final length = int.parse(
      utf8.decode(buf.sublist(offset + 1, lengthLineEnd)),
    );
    if (length == -1) return (null, lengthLineEnd + 2);
    final dataStart = lengthLineEnd + 2;
    final dataEnd = dataStart + length;
    if (dataEnd + 2 > buf.length) return null;
    final value = utf8.decode(buf.sublist(dataStart, dataEnd));
    return (value, dataEnd + 2);
  }

  static (List<dynamic>, int)? _parseArray(Uint8List buf, int offset) {
    final countLineEnd = _findCrlf(buf, offset + 1);
    if (countLineEnd == -1) return null;
    final count = int.parse(utf8.decode(buf.sublist(offset + 1, countLineEnd)));
    var pos = countLineEnd + 2;
    final items = <dynamic>[];

    for (var i = 0; i < count; i++) {
      final result = _parseValue(buf, pos);
      if (result == null) return null;
      final (value, newPos) = result;
      items.add(value);
      pos = newPos;
    }

    return (items, pos);
  }

  static int _findCrlf(Uint8List buf, int start) {
    for (var i = start; i < buf.length - 1; i++) {
      if (buf[i] == 13 && buf[i + 1] == 10) return i;
    }
    return -1;
  }

  static Uint8List _toBytes(String s) => Uint8List.fromList(utf8.encode(s));
}
