import 'package:dartis/src/data/models/command_dispatcher.dart';
import 'package:dartis/src/data/models/tcp_server.dart';
import 'package:dartis/src/data/repositories/in_memory_store_repository.dart';
import 'package:dartis/src/domain/domain.dart';

void main() async {
  final store = InMemoryStoreRepository();
  final dispatcher = CommandDispatcher(
    setKey: SetKey(store),
    getKey: GetKey(store),
    deleteKey: DeleteKey(store),
    expireKey: ExpireKey(store),
    listKeys: ListKeys(store),
    existsKey: ExistsKey(store),
    getTimeLeft: GetTimeLeft(store),
    persistKey: PersistKey(store),
    flushAll: FlushAll(store),
  );
  final server = TcpServer(port: 6379, dispatcher: dispatcher);

  await server.start();
  print('Listening on port 6379');
}
