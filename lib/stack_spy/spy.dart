/*
 * Created with Android Studio.
 * User: whqfor
 * Date: 12/7/20
 * Time: 11:04 AM
 * target: spy
 */

import 'dart:async';

import 'package:d_spy/d_spy.dart';

import 'spy_channel.dart';
import 'package:flutter/services.dart';
import 'spy_socket.dart';


class DSpy {
  static final DSpy _singleton = DSpy._internal();
  factory DSpy() => _singleton;
  static DSpy get instance => _singleton;


  DChannel get channel => _stackChannel;
  static DChannel _stackChannel;

  void ipAndPort(String ipAndPort) {
    SpySocket().initSocket(ipAndPort);
  }

  int milliseconds;
  DSpyNodeObserver nodeObserver;

  DSpy._internal() {
    print('DSpy instance');
    final MethodChannel _methodChannel = MethodChannel("d_spy");
    _stackChannel = DChannel(_methodChannel);
  }

  static Future<String> get platformVersion async {
    final String version =
    await _stackChannel.invokeMethod('getPlatformVersion');
    print('spy $version');
    return version;
  }
}