import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

class Worker {
  late SendPort sendPort;
  final Completer<void> isolateReady = Completer.sync();

  Future<void> spawn() async {
    final receivePort = ReceivePort();
    receivePort.listen(handleResponsesFromIsolate);
    await Isolate.spawn(startRemoteIsolate, receivePort.sendPort);
  }

  void handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      sendPort = message;
      isolateReady.complete();
    } else if (message is Map<String, dynamic>) {
      print(message);
    }
  }

  static void startRemoteIsolate(SendPort port) {
    final receivePort = ReceivePort();
    port.send(receivePort.sendPort);

    receivePort.listen((dynamic message) async {
      if (message is String) {
        final transformed = jsonDecode(message);
        port.send(transformed);
      }
    });
  }

  Future<void> sendMessageToIsolate(Object o) async {
    await isolateReady.future;
    sendPort.send(o);
  }

}
