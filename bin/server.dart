import 'package:dartis/src/data/models/command_dispatcher.dart';
import 'package:dartis/src/data/models/tcp_server.dart';
import 'package:dartis/src/data/repositories/in_memory_store_repository.dart';

void main() async {
  final store = InMemoryStoreRepository();
  final dispatcher = CommandDispatcher(store: store);
  final server = TcpServer(port: 6379, dispatcher: dispatcher);

  await server.start();
  print('Listening on port 6379');
}
