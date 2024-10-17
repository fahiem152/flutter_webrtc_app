import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCExample extends StatefulWidget {
  @override
  _WebRTCExampleState createState() => _WebRTCExampleState();
}

class _WebRTCExampleState extends State<WebRTCExample> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  IO.Socket? _socket;
  String? _remoteId;

  @override
  void initState() {
    super.initState();
    initRenderers();
    connectToSocket();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    _socket?.dispose();
    super.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void connectToSocket() {
    _socket =
        IO.io('https://fa14-202-111-5-214.ngrok-free.app', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket?.on('connect', (_) {
      print('Connected to the server');
    });

    _socket?.on('ada user lain', (data) async {
      _remoteId = data[0]; // Assuming the data is an array of user IDs
      await createPeerConnection();
    });

    _socket?.on('offer', (data) async {
      final description =
          RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
      await createPeerConnection();
      await _peerConnection?.setRemoteDescription(description);
      final answer = await _peerConnection?.createAnswer();
      await _peerConnection?.setLocalDescription(answer!);
      _socket?.emit('answer', {
        'answer': {
          'sdp': answer!.sdp,
          'type': answer.type,
        },
        'to': data['from'],
      });
    });

    _socket?.on('answer', (data) async {
      final description =
          RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
      await _peerConnection?.setRemoteDescription(description);
    });

    _socket?.on('ice candidate', (data) async {
      final candidate = RTCIceCandidate(data['candidate']['candidate'],
          data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']);
      await _peerConnection?.addCandidate(candidate);
    });
  }

  Future<void> createPeerConnection() async {
    if (_peerConnection != null) return; // Don't recreate if already exists

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) {
        _socket?.emit(
            'ice candidate', {'candidate': candidate.toMap(), 'to': _remoteId});
      }
    };

    _peerConnection?.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    _localStream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    _localRenderer.srcObject = _localStream;

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    final offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);
    _socket?.emit('offer', {
      'offer': {
        'sdp': offer!.sdp,
        'type': offer.type,
      },
      'to': _remoteId,
    });
  }

  @override
  Widget build(BuildContext context) {
    log("_build: $_localRenderer");
    log("_build2: $_remoteRenderer");
    return Scaffold(
      appBar: AppBar(title: Text('WebRTC Example')),
      body: Column(
        children: [
          Text("User Local"),
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          const SizedBox(
            height: 32.0,
          ),
          Text("User Remote"),
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
        ],
      ),
    );
  }
}
