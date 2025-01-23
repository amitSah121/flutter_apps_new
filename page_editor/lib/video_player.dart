import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDisplay extends StatefulWidget {
  final bool b1;
  final String parsedT;
  final String t2;
  final String defaultAppPath;
  final double width;
  final double height;

  const VideoDisplay({
    required this.b1,
    required this.parsedT,
    required this.t2,
    required this.defaultAppPath,
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (!widget.b1) {
      _controller = VideoPlayerController.networkUrl(Uri(path: widget.parsedT))
        ..initialize().then((_) {
          setState(() {}); // Refresh to show the video
        });
    } else {
      _controller = VideoPlayerController.file(File("/storage/emulated/0/PageEditor/${widget.t2}"))
        ..initialize().then((_) {
          setState(() {}); // Refresh to show the video
        });
    }
    _controller.setLooping(true); // Loop the video
    _controller.setVolume(0);
    // _controller.play(); // Auto-play the video
    // _controller.;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      if (_controller.value.volume == 0) {
        _controller.setVolume(1);
      } else {
        _controller.setVolume(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            decoration: const BoxDecoration(color: Colors.black12, borderRadius: const BorderRadius.all(Radius.circular(24))),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: Icon(
                    _controller.value.volume == 0 ? Icons.volume_off : Icons.volume_mute,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: _toggleMute,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
