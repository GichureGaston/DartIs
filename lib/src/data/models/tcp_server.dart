import 'dart:io';
import 'dart:typed_data';

import 'command_dispatcher.dart';
import 'resp_codec.dart';

class TcpServer {
  final int port;
  final CommandDispatcher dispatcher;

  ServerSocket? _socket;
  final _clients = <Socket>{};

  TcpServer({required this.port, required this.dispatcher});

  Future<void> start() async {
    _socket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _socket!.listen(_handleClient);
  }

  Future<void> stop() async {
    for (final client in _clients) {
      await client.close();
    }
    await _socket?.close();
  }

  void _handleClient(Socket client) {
    _clients.add(client);
    var buffer = Uint8List(0);

    client.listen(
      (Uint8List data) {
        buffer = Uint8List.fromList([...buffer, ...data]);

        final (commands, remaining) = RespCodec.decode(buffer);
        buffer = remaining;

        for (final command in commands) {
          final response = dispatcher.dispatch(command);
          client.add(response);
        }
      },
      onError: (_) {
        _clients.remove(client);
        client.destroy();
      },
      onDone: () {
        _clients.remove(client);
        client.destroy();
      },
    );
  }
}
