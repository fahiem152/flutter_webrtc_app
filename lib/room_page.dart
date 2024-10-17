// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter_webrtc_app/signaling.dart';

class RoomPage extends StatefulWidget {
  final String roomId;
  final bool isCreated;

  const RoomPage({
    Key? key,
    required this.roomId,
    required this.isCreated,
  }) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      log("OnAddRemoteStream: ${stream.id}");

      setState(() {});
    });

    if (widget.isCreated) {
      signaling.openUserMedia(_localRenderer, _remoteRenderer);
    } else {
      // signaling.openUserMedia(_localRenderer, _remoteRenderer);
      signaling.joinRoom(
        widget.roomId,
        _remoteRenderer,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard2() async {
    print("RUNNING2: ${widget.roomId}");
    await Clipboard.setData(ClipboardData(text: widget.roomId));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Room - ${widget.roomId}"),
            const SizedBox(
              width: 4.0,
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard2,
            ),
          ],
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                    SizedBox(
                      width: 20,
                    ),
                    _remoteRenderer.srcObject != null
                        ? Container(
                            height: 100,
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                            ),
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                          ),
                    // Expanded(
                    //   child: RTCVideoView(_remoteRenderer),
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
