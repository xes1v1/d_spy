/*
 * Created with Android Studio.
 * User: whqfor
 * Date: 12/1/20
 * Time: 4:11 PM
 * target: Spy channel
 */

import 'dart:async';
import 'package:d_spy/stack_spy/spy.dart';
import 'package:flutter/services.dart';

const String SpySendScreenShotActionToNative = 'spySendScreenShotActionToNative';
const String SpyReceiveScreenShotFromNative = 'spyReceiveScreenShotFromNative';

class DChannel {
  MethodChannel _methodChannel;

  DChannel(MethodChannel methodChannel) {
    _methodChannel = methodChannel;
    _methodChannel.setMethodCallHandler((MethodCall call) {
      // 处理Native发过来的消息
      print(
          'setMethodCallHandler method ${call.method}');
      if (SpyReceiveScreenShotFromNative == call.method) {
        // 接受到截图信息发给socket处理
        DSpy.instance.nodeObserver.addScreenshotNode(call.arguments);
      }
      return Future.value();
    });
  }

  void sendScreenShotActionToNative(Map action) {
    invokeMethod(SpySendScreenShotActionToNative, action);
  }

  Future invokeMethod<T>(String method, [dynamic arguments]) async {
    return _methodChannel.invokeMethod(method, arguments);
  }
}