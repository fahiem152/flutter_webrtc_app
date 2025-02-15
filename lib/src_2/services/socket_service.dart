import 'package:flutter/material.dart';
import 'package:flutter_webrtc_app/src_2/common/styles.dart';
import 'package:flutter_webrtc_app/src_2/repository/friend_repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SocketService {
  final _socketResponse = StreamController<List<dynamic>>();
  final _getListUser = StreamController<List<dynamic>>();
  final _typingController = StreamController<dynamic>();
  final _userController = StreamController<dynamic>();
  final _scrollController = ScrollController();
  var _userInfo, _room = 'chating';
  List<dynamic> _allMessage = [];
  List<dynamic> _allUser = [];
  late IO.Socket socket;

  get room => _room;

  createSocketConnection() {
    _userController.add(friends[0]);
    _userInfo = friends[0];
    socket = IO.io('http://192.168.1.8:3000/',
        IO.OptionBuilder().setTransports(['websocket']).build());
    socket.connect();
    socket.onConnect((_) {
      print('connect');
      socket.emit('join', myId);
      // Join room
      socket.emit('subscribe', _room);

      subscribe();
    });

    socket.onDisconnect((_) => print('disconnect'));
  }

  subscribe() {
    socket.on('list-user', (data) {
      _allUser.clear();
      _allUser.addAll(data);
      _allUser = _allUser.reversed.toList();
      _getListUser.add(_allUser);
    });

    socket.on('precence', (data) {
      _allUser.clear();
      _allUser.addAll(data);
      _allUser = _allMessage.reversed.toList();
      _getListUser.add(_allUser);
    });

    socket.on('$myId-$_room-history', (data) {
      _allMessage.clear();
      _allMessage.addAll(data);
      _allMessage = _allMessage.reversed.toList();
      _socketResponse.add(_allMessage);
      scrollToBottom();
    });

    socket.on(_room, (data) {
      _allMessage.insert(0, data);
      _socketResponse.add(_allMessage);
      scrollToBottom();
    });

    socket.on('$_room-typing', (data) {
      _typingController.add(data);
    });
  }

  sendMessage(msg) {
    _allMessage.insert(0, {
      'msg': msg,
      'id': myId,
    });
    socket.emit(_room, msg.toString());
  }

  isTyping(isTyping) {
    socket.emit('$_room-typing', {
      'id': myId,
      'isTyping': isTyping,
      'name': 'lambiengcode',
    });
  }

  void Function(List<dynamic>) get addResponse => _socketResponse.sink.add;

  Stream<List<dynamic>> get getResponse => _socketResponse.stream;

  Stream<List<dynamic>> get getListUser => _getListUser.stream;

  Stream<dynamic> get getTyping => _typingController.stream;

  ScrollController get getScrollController => _scrollController;

  void setUserInfo(dynamic info) {
    socket.emit('join', info['id']);
    // Join room
    socket.emit('subscribe', _room);

    subscribe();

    _userController.add(info);
    _userInfo = info;
    _allMessage.clear();
    _socketResponse.add(_allMessage);
    // this.socket.emit('unsubscribe', _room);
    // _room = info['name'];
    // this.socket.emit('subscribe', _room);
    // subscribe();
  }

  Stream<dynamic> get getUserInfo => _userController.stream;

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 100),
      );
    }
  }

  void dispose() {
    _socketResponse.close();
    _typingController.close();
    _userController.close();
  }
}
