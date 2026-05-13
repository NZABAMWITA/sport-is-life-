import 'dart:async'; // Add this import for Timer
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String calleeName;
  final bool isCaller;
  final String callType; // 'video' or 'audio'

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.calleeName,
    required this.isCaller,
    required this.callType,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  static const String appId = "43827fc539ab4ea48b67f1e7ac884123";
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  int _callDuration = 0;
  Timer? _timer; // Changed to nullable Timer

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startTimer();
  }

  Future<void> _initAgora() async {
    try {
      // Request permissions
      await [Permission.camera, Permission.microphone].request();

      // Create engine
      _engine = createAgoraRtcEngine();
      await _engine?.initialize(const RtcEngineContext(appId: appId));

      // Set up event handlers
      _engine?.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _isJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() => _remoteUid = null);
        },
      ));

      // Enable video for video calls
      if (widget.callType == 'video') {
        await _engine?.enableVideo();
      }

      // Join channel
      await _engine?.joinChannel(
        token: '',
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      print('Error initializing Agora: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize call: $e')),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video
          if (_remoteUid != null && widget.callType == 'video')
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid!),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            )
          else if (_remoteUid == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Waiting for ${widget.calleeName} to join...',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Local video (picture-in-picture)
          if (_isJoined && widget.callType == 'video')
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                    connection: RtcConnection(channelId: widget.channelName),
                  ),
                ),
              ),
            ),

          // Call duration
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatDuration(_callDuration),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          // Call controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    color: _isMuted ? Colors.red : Colors.white,
                    onPressed: _toggleMute,
                  ),

                  // Video toggle (for video calls)
                  if (widget.callType == 'video')
                    _buildControlButton(
                      icon:
                          _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      label: _isVideoEnabled ? 'Video On' : 'Video Off',
                      color: _isVideoEnabled ? Colors.white : Colors.red,
                      onPressed: _toggleVideo,
                    ),

                  // Switch camera (for video calls)
                  if (widget.callType == 'video')
                    _buildControlButton(
                      icon: Icons.switch_camera,
                      label: 'Switch',
                      color: Colors.white,
                      onPressed: _switchCamera,
                    ),

                  // End call
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'End',
                    color: Colors.red,
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Future<void> _toggleMute() async {
    await _engine?.muteLocalAudioStream(!_isMuted);
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _toggleVideo() async {
    await _engine?.enableLocalVideo(!_isVideoEnabled);
    setState(() => _isVideoEnabled = !_isVideoEnabled);
  }

  Future<void> _switchCamera() async {
    await _engine?.switchCamera();
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  Future<void> _endCall() async {
    _timer?.cancel();
    await CallService.endCall(widget.channelName);
    await _engine?.leaveChannel();
    await _engine?.release();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }
}
