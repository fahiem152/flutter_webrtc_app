// ignore: uri_does_not_exist
import 'dart:core';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/*
 * getUserMedia sample
 */
class GetUserMediaWeb extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  @override
  _GetUserMediaWebState createState() => _GetUserMediaWebState();
}

class _GetUserMediaWebState extends State<GetUserMediaWeb> {
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool isShereScreen = false;
  MediaRecorder? _mediaRecorder;
  DesktopCapturerSource? selected_source_;

  List<MediaDeviceInfo>? _cameras;

  bool get _isRec => _mediaRecorder != null;
  List<dynamic>? cameras;

  bool isAudioOn = false;
  bool isVideoOn = true;

  @override
  void initState() {
    super.initState();
    initRenderers();

    // navigator.mediaDevices.enumerateDevices().then((md) {
    //   setState(() {
    //     cameras = md.where((d) => d.kind == 'videoinput').toList();
    //   });
    // });
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _stop();
    }
    _localRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _makeCallShareScreen(DesktopCapturerSource? source) async {
    setState(() {
      selected_source_ = source;
    });

    try {
      var stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': selected_source_ == null
            ? true
            : {
                'deviceId': {'exact': selected_source_!.id},
                'mandatory': {'frameRate': 30.0}
              }
      });
      stream.getVideoTracks()[0].onEnded = () {
        print(
            'By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };

      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      isShereScreen = true;
    });
  }

  Future<void> selectScreenSourceDialog(BuildContext context) async {
    if (WebRTC.platformIsDesktop) {
      final source = await showDialog<DesktopCapturerSource>(
          context: context,
          builder: (context) => const AlertDialog(
                content: Text("WebRTC platformIsDesktop"),
              ));
      if (source != null) {
        await _makeCallShareScreen(source);
      }
    } else {
      if (WebRTC.platformIsAndroid) {
        // Android specific
        Future<void> requestBackgroundPermission([bool isRetry = false]) async {
          // Required for android screenshare.
          try {
            var hasPermissions = await FlutterBackground.hasPermissions;
            if (!isRetry) {
              const androidConfig = FlutterBackgroundAndroidConfig(
                notificationTitle: 'Screen Sharing',
                notificationText: 'LiveKit Example is sharing the screen.',
                notificationImportance: AndroidNotificationImportance.Default,
                notificationIcon: AndroidResource(
                    name: 'livekit_ic_launcher', defType: 'mipmap'),
              );
              hasPermissions = await FlutterBackground.initialize(
                  androidConfig: androidConfig);
            }
            if (hasPermissions &&
                !FlutterBackground.isBackgroundExecutionEnabled) {
              await FlutterBackground.enableBackgroundExecution();
            }
          } catch (e) {
            if (!isRetry) {
              return await Future<void>.delayed(const Duration(seconds: 1),
                  () => requestBackgroundPermission(true));
            }
            print('could not publish video: $e');
          }
        }

        await requestBackgroundPermission();
      }
      await _makeCallShareScreen(null);
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
      }
    };

    try {
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _cameras = await Helper.cameras;
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  void _hangUp() async {
    await _stop();
    setState(() {
      _inCalling = false;
    });
  }

  void _stopShareScreen() async {
    await _stop();
    setState(() {
      isShereScreen = false;
    });
  }

  void _startRecording() async {
    if (_localStream == null) throw Exception('Can\'t record without a stream');
    _mediaRecorder = MediaRecorder();
    setState(() {});
    _mediaRecorder?.startWeb(_localStream!);
  }

  void _stopRecording() async {
    final objectUrl = await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });
    print(objectUrl);
    // ignore: unsafe_html
    html.window.open(objectUrl, '_blank');
  }

  void _captureFrame() async {
    if (_localStream == null) throw Exception('Can\'t record without a stream');
    final videoTrack = _localStream!
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    final frame = await videoTrack.captureFrame();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content:
                  Image.memory(frame.asUint8List(), height: 720, width: 1280),
              actions: <Widget>[
                TextButton(
                  onPressed: Navigator.of(context, rootNavigator: true).pop,
                  child: const Text('OK'),
                )
              ],
            ));
  }

  void _toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    // change status
    isVideoOn = !isVideoOn;

    // enable or disable video track
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GetUserMedia API Test Web'),
        actions: _inCalling
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.camera),
                  onPressed: _captureFrame,
                ),
                IconButton(
                  icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
                  onPressed: _isRec ? _stopRecording : _startRecording,
                ),
                // PopupMenuButton<String>(
                //   onSelected: _switchCamera,
                //   itemBuilder: (BuildContext context) {
                //     if (_cameras != null) {
                //       return _cameras!.map((device) {
                //         return PopupMenuItem<String>(
                //           value: device.deviceId,
                //           child: Text(device.label),
                //         );
                //       }).toList();
                //     } else {
                //       return [];
                //     }
                //   },
                // ),
                // IconButton(
                //   icon: Icon(Icons.settings),
                //   onPressed: _switchCamera,
                // )
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: isShereScreen
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white10,
                    child: Stack(children: <Widget>[
                      if (_inCalling)
                        Container(
                          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration:
                              const BoxDecoration(color: Colors.black54),
                          child: RTCVideoView(_localRenderer),
                        )
                    ]),
                  )
                : Container(
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(color: Colors.black54),
                    child: RTCVideoView(_localRenderer, mirror: true),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                onPressed: _toggleMic,
              ),
              IconButton(
                icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
                onPressed: _toggleCamera,
              ),
              IconButton(
                icon: Icon(isShereScreen
                    ? Icons.stop_screen_share_outlined
                    : Icons.screen_share_outlined),
                onPressed: () {
                  isShereScreen
                      ? _stopShareScreen()
                      : selectScreenSourceDialog(context);
                },
              ),
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  // void _switchCamera(String deviceId) async {
  //   if (_localStream == null) return;

  //   await Helper.switchCamera(
  //       _localStream!.getVideoTracks()[0], deviceId, _localStream);
  //   setState(() {});
  // }
}
