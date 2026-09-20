import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  final StreamController<MediaStream> _remoteStreamController =
      StreamController<MediaStream>.broadcast();

  final StreamController<RTCPeerConnectionState>
      _connectionStateController =
      StreamController<RTCPeerConnectionState>.broadcast();

  bool isMuted = false;
  bool isSpeakerOn = false;

  Stream<MediaStream> get remoteStream =>
      _remoteStreamController.stream;

  Stream<RTCPeerConnectionState> get connectionState =>
      _connectionStateController.stream;

  RTCPeerConnection? get peerConnection => _peerConnection;

  MediaStream? get localStream => _localStream;

  bool get hasMicrophone => _localStream != null;

  bool get isInitialized => _peerConnection != null;

  // ---------------------------------------------------------------------------
  // INITIALIZE
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_peerConnection != null) {
      return;
    }

    _localStream =
        await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    _peerConnection =
        await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun.l.google.com:19302',
            'stun:stun1.l.google.com:19302',
          ],
        },
      ],
    });

    final connection = _peerConnection!;

    connection.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams.first;

        if (!_remoteStreamController.isClosed) {
          _remoteStreamController.add(stream);
        }
      }
    };

    connection.onConnectionState = (
      RTCPeerConnectionState state,
    ) {
      if (!_connectionStateController.isClosed) {
        _connectionStateController.add(state);
      }
    };

    for (final track in _localStream!.getTracks()) {
      await connection.addTrack(
        track,
        _localStream!,
      );
    }

    await Helper.setSpeakerphoneOn(false);
    isSpeakerOn = false;
    isMuted = false;
  }

  // ---------------------------------------------------------------------------
  // CREATE OFFER
  // ---------------------------------------------------------------------------

  Future<RTCSessionDescription> createOffer() async {
    final connection = _peerConnection;

    if (connection == null) {
      throw StateError(
        'CallService has not been initialized.',
      );
    }

    final offer = await connection.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': false,
    });

    await connection.setLocalDescription(offer);

    return offer;
  }

  // ---------------------------------------------------------------------------
  // CREATE ANSWER
  // ---------------------------------------------------------------------------

  Future<RTCSessionDescription> createAnswer() async {
    final connection = _peerConnection;

    if (connection == null) {
      throw StateError(
        'CallService has not been initialized.',
      );
    }

    final answer = await connection.createAnswer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': false,
    });

    await connection.setLocalDescription(answer);

    return answer;
  }

  // ---------------------------------------------------------------------------
  // SET REMOTE DESCRIPTION
  // ---------------------------------------------------------------------------

  Future<void> setRemoteDescription(
    String sdp,
    String type,
  ) async {
    final connection = _peerConnection;

    if (connection == null) {
      throw StateError(
        'CallService has not been initialized.',
      );
    }

    await connection.setRemoteDescription(
      RTCSessionDescription(
        sdp,
        type,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADD REMOTE ICE CANDIDATE
  // ---------------------------------------------------------------------------

  Future<void> addRemoteIceCandidate(
    Map<String, dynamic> data,
  ) async {
    final connection = _peerConnection;

    if (connection == null) {
      return;
    }

    final candidate = data['candidate'] as String?;

    if (candidate == null || candidate.isEmpty) {
      return;
    }

    final sdpMid = data['sdpMid'] as String?;

    final sdpMLineIndexValue =
        data['sdpMLineIndex'];

    int? sdpMLineIndex;

    if (sdpMLineIndexValue is int) {
      sdpMLineIndex = sdpMLineIndexValue;
    } else if (sdpMLineIndexValue is num) {
      sdpMLineIndex =
          sdpMLineIndexValue.toInt();
    }

    await connection.addCandidate(
      RTCIceCandidate(
        candidate,
        sdpMid,
        sdpMLineIndex,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MUTE
  // ---------------------------------------------------------------------------

  Future<void> toggleMute() async {
    if (_localStream == null) {
      return;
    }

    final tracks =
        _localStream!.getAudioTracks();

    if (tracks.isEmpty) {
      return;
    }

    isMuted = !isMuted;

    for (final track in tracks) {
      track.enabled = !isMuted;
    }
  }

  // ---------------------------------------------------------------------------
  // SPEAKER
  // ---------------------------------------------------------------------------

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;

    await Helper.setSpeakerphoneOn(
      isSpeakerOn,
    );
  }

  // ---------------------------------------------------------------------------
  // STOP MICROPHONE
  // ---------------------------------------------------------------------------

  Future<void> stopMicrophone() async {
    if (_localStream == null) {
      return;
    }

    for (final track
        in _localStream!.getAudioTracks()) {
      track.enabled = false;
    }

    isMuted = true;
  }

  // ---------------------------------------------------------------------------
  // END CALL
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    final connection = _peerConnection;
    final stream = _localStream;

    _peerConnection = null;
    _localStream = null;

    if (stream != null) {
      for (final track in stream.getTracks()) {
        try {
          await track.stop();
        } catch (_) {}
      }

      try {
        await stream.dispose();
      } catch (_) {}
    }

    if (connection != null) {
      try {
        await connection.close();
      } catch (_) {}
    }

    isMuted = false;
    isSpeakerOn = false;
  }

  // ---------------------------------------------------------------------------
  // COMPLETE CLEANUP
  // ---------------------------------------------------------------------------

  Future<void> disposeController() async {
    await dispose();

    await _remoteStreamController.close();
    await _connectionStateController.close();
  }
}