import 'dart:io';
// import 'dart:core';
// import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';

class UserMedia extends StatefulWidget {
  @override
  _UserMediaState createState() => _UserMediaState();
}

class _UserMediaState extends State<UserMedia> {
  MediaStream _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  bool _isTorchOn = false;
  MediaRecorder _mediaRecorder;
  bool get _isRec => _mediaRecorder != null;
  // List<dynamic> cameras;

  @override
  void initState() {
    super.initState();
    initRenderer();

    // MediaDevices.getSources().then((md) {
    //   setState(() {
    //     cameras = md.where((d) => d['kind'] == 'videoinput').toList();
    //   });
    // });
  }

  @override
  void deactivate() {
    super.deactivate();

    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
  }

  Future<void> initRenderer() async {
    await _localRenderer.initialize();
  }

  // make localStream visiable
  Future<void> _makeCall() async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    try {
      var stream = await MediaDevices.getUserMedia(mediaConstraints);
      // var stream = await MediaDevices.getDisplayMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream = stream;
    } catch (e) {
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });
  }

  // it dispose the localStream
  void _hangUp() async {
    try {
      await _localStream.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _inCalling = false;
    });
  }

  // TODO: It's need to be implemented fully
  void _startRecording() async {
    if (Platform.isIOS) {
      print('Recording is not available on iOS');
      return;
    }

    final storagePath = await getApplicationDocumentsDirectory();
    final filePath = storagePath.path + '/recording/lepit${DateTime.now()}.mp4';
    _mediaRecorder = MediaRecorder();
    setState(() {});
    await _localStream.getMediaTracks();
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await _mediaRecorder.start(
      filePath,
      videoTrack: videoTrack,
    );

    // for web
    // _mediaRecoder.startWeb(_localStream);
  }

  void _stopRecording() async {
    await _mediaRecorder?.stop();
    setState(() {
      _mediaRecorder = null;
    });

    // for web
    // final objectUrl = await _mediaRecorder?.stop();
    // setState(() {
    //   _mediaRecorder = null;
    // });
    // print(objectUrl);
    // html.window.open(objectUrl, '_blank');
  }

  // it on the torch where faceMode is
  void _toggleTorch() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');

    final hasTorch = await videoTrack.hasTorch();
    if (hasTorch) {
      print('[TORCH] Current camera supports torch mode');
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
      await videoTrack.setTorch(_isTorchOn);
      print('[TORCH] Torch state is now ${_isTorchOn ? 'on' : 'off'}');
    } else {
      print('[TORCH] Current camera does not support torch mode');
    }
  }

  // It's toggle the faceMode [user] or [enviornment]
  void _toggleCamera() async {
    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');

    await videoTrack.switchCamera();
  }

  // Some problem in package code
  void _captureFrame() async {
    final storagePath = await getApplicationDocumentsDirectory();
    String filePath = storagePath.path + '/lepit${DateTime.now()}.png';

    final videoTrack = _localStream
        .getVideoTracks()
        .firstWhere((track) => track.kind == 'video');
    await videoTrack.captureFrame(filePath);

    // for web
    // final frame = await videoTrack.captureFrame();
    // await showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     content: Image.network(frame, height: 720, width: 1280),
    //     actions: <Widget>[
    //       FlatButton(
    //         child: Text('OK'),
    //         onPressed: Navigator.of(context, rootNavigator: true).pop,
    //       )
    //     ],
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _inCalling
            ? [
                IconButton(
                  tooltip: _isTorchOn ? 'Flash Off' : 'Flash On',
                  icon: Icon(_isTorchOn ? Icons.flash_off : Icons.flash_on),
                  onPressed: _toggleTorch,
                ),
                IconButton(
                  tooltip: 'Switch Camera',
                  icon: Icon(Icons.switch_video),
                  onPressed: _toggleCamera,
                ),
                IconButton(
                  tooltip: 'Capture Frame',
                  icon: Icon(Icons.camera),
                  onPressed: _captureFrame,
                ),
                IconButton(
                  tooltip: _isRec ? 'Stop Recording' : 'Start Recording',
                  icon: Icon(_isRec ? Icons.stop : Icons.fiber_manual_record),
                  onPressed: _isRec ? _stopRecording : _startRecording,
                ),
              ]
            : null,
      ),
      // body: Container(
      //   child: new Stack(
      //     children: <Widget>[
      //       new Positioned(
      //         top: 0.0,
      //         right: 0.0,
      //         left: 0.0,
      //         bottom: 0.0,
      //         child: new Container(
      //           child: new RTCVideoView(
      //             _localRenderer,
      //             mirror: true,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Stack(children: [
              Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
                decoration: BoxDecoration(color: Colors.black54),
              ),
            ]),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
