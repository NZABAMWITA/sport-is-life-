import 'package:flutter/material.dart';
import 'video_call_screen.dart';
import '../services/call_service.dart';

class IncomingCallScreen extends StatefulWidget {
  final Map<String, dynamic> callData;

  const IncomingCallScreen({super.key, required this.callData});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green.withOpacity(0.2),
                      child: Icon(
                        widget.callData['callType'] == 'video'
                            ? Icons.videocam
                            : Icons.call,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Incoming ${widget.callData['callType'] == 'video' ? 'Video' : 'Audio'} Call',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.callData['fromName'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'is calling you...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.call_end, size: 30),
                          color: Colors.white,
                          onPressed: _declineCall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Decline',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  // Accept button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.green,
                        child: IconButton(
                          icon: Icon(
                            widget.callData['callType'] == 'video'
                                ? Icons.videocam
                                : Icons.call,
                            size: 30,
                          ),
                          color: Colors.white,
                          onPressed: _acceptCall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptCall() async {
    await CallService.acceptCall(widget.callData['channelName']);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            channelName: widget.callData['channelName'],
            calleeName: widget.callData['fromName'],
            isCaller: false,
            callType: widget.callData['callType'],
          ),
        ),
      );
    }
  }

  void _declineCall() {
    Navigator.pop(context);
  }
}
