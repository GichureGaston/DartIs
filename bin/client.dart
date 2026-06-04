import 'dart:io';
import 'dart:typed_data';

String resp(List<String> parts) {
  final buffer = StringBuffer();
  buffer.write('*${parts.length}\r\n');
  for (final part in parts) {
    buffer.write('\$${part.length}\r\n$part\r\n');
  }
  return buffer.toString();
}

const help = '''
AVAILABLE COMMANDS

  Connectivity
    PING              Check server is alive
    PING <msg>        Echo a message back

  Strings
    SET k v           Set a key
    SET k v EX s      Set with expiry in seconds
    SET k v PX ms     Set with expiry in milliseconds
    SET k v NX        Set only if key does not exist
    SET k v XX        Set only if key already exists
    GET k             Get a key
    DEL k1 k2 ...     Delete one or more keys
    EXISTS k1 k2      Count how many of the keys exist

  Expiry
    EXPIRE k s        Set expiry in seconds
    PEXPIRE k ms      Set expiry in milliseconds
    TTL k             Time to live in seconds
    PTTL k            Time to live in milliseconds
    PERSIST k         Remove expiry from a key

  Store
    KEYS *            List all keys
    KEYS user:*       List keys matching a pattern
    FLUSHALL          Delete every key in the store

  Client
    HELP              Show this list
    EXIT              Quit the client

TTL return values
    -1  key exists but has no expiry
    -2  key does not exist
''';

void main() async {
  final socket = await Socket.connect('localhost', 6379);

  socket.listen((Uint8List data) {
    print('< ${String.fromCharCodes(data).trim()}');
  });

  print('Connected to Redis server on port 6379');
  print('Type HELP to see available commands');
  print('Type EXIT to quit\n');

  while (true) {
    stdout.write('> ');
    final line = stdin.readLineSync();

    if (line == null || line.trim().toUpperCase() == 'EXIT') break;
    if (line.trim().isEmpty) continue;

    if (line.trim().toUpperCase() == 'HELP') {
      print(help);
      continue;
    }

    final parts = line.trim().split(' ');
    socket.write(resp(parts));
    await Future.delayed(Duration(milliseconds: 200));
  }

  socket.destroy();
  print('Disconnected.');
}
