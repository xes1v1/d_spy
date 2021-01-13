/*
 * Created with Android Studio.
 * User: whqfor
 * Date: 12/7/20
 * Time: 10:36 AM
 * target: socket通信
 */

import 'dart:async';
import 'dart:io';

import 'package:d_spy/stack_spy/spy.dart';

class SpySocket {
  WebSocket socket;

  Future<WebSocket> initSocket(String ipAndPort) async {
    // Dart client
    // ws://10.29.13.38:4041/ws
    print('spy initSocket');

    WebSocket _socket = await WebSocket.connect('ws://$ipAndPort/ws');
    socket = _socket;
    print('spy initSocket done');

    // 需要给前端页面预留启动时间
    Future.delayed(Duration(milliseconds: 3000), () {

      Timer.periodic(Duration(milliseconds: 300), (timer) {
        var sentStr =  DSpy.instance.nodeObserver.firstNodeString();
        if (sentStr != null) {
          print('sentSocket');
          sentNodeToServer(sentStr);
        }
      });

    });

    return _socket;
  }

  void listenSocket() {
    socket.listen((event) {
      print('event $event');
      // 接受到截图消息准备native截图
      // 处理好格式后发给native
      Map action = event;
      DSpy.instance.channel
          .sendScreenShotActionToNative({'target': action['target']});
    });
  }

  void sentNodeToServer(String jsonString) {
    socket.add(jsonString);
  }
}
