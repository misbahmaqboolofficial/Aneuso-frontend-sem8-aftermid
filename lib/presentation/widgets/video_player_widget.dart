import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final String? title;

  const VideoPlayerWidget({Key? key, required this.url, this.title})
    : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  YoutubePlayerController? _ytController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _error;

  String? _extractYoutubeVideoId(String url) {
    try {
      // Check if it's a placeholder URL
      if (url.contains('example') || url.contains('placeholder')) {
        return null; // Indicate this is a placeholder
      }

      // Try youtube_player_flutter's built-in method
      final id = YoutubePlayer.convertUrlToId(url);
      if (id != null && id.isNotEmpty && !id.contains('example')) return id;

      // Fallback: manual extraction from common YouTube URL formats
      if (url.contains('youtube.com') || url.contains('youtu.be')) {
        // https://www.youtube.com/watch?v=VIDEO_ID
        if (url.contains('watch?v=')) {
          final extracted = url.split('watch?v=').last.split('&').first;
          if (extracted.isNotEmpty && !extracted.contains('example'))
            return extracted;
        }
        // https://youtu.be/VIDEO_ID
        if (url.contains('youtu.be/')) {
          final extracted = url.split('youtu.be/').last.split('?').first;
          if (extracted.isNotEmpty && !extracted.contains('example'))
            return extracted;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool get isYoutube {
    if (widget.url.isEmpty) return false;
    return _extractYoutubeVideoId(widget.url) != null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.url.isEmpty) {
      _error = 'No video URL provided';
      return;
    }

    // Check for placeholder URLs
    if (widget.url.contains('example') || widget.url.contains('placeholder')) {
      _error =
          'This is a placeholder video URL. Please update the database with real YouTube links.\n\nExample format: https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      return;
    }

    if (isYoutube) {
      final videoId = _extractYoutubeVideoId(widget.url);
      if (videoId != null && videoId.isNotEmpty) {
        try {
          _ytController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: true,
            ),
          );
        } catch (e) {
          _error = 'Failed to initialize YouTube player: $e';
        }
      } else {
        _error = 'Invalid YouTube URL: Could not extract video ID';
      }
    } else {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize()
            .then((_) {
              if (mounted) {
                _chewieController = ChewieController(
                  videoPlayerController: _videoController!,
                  autoPlay: false,
                  looping: false,
                  materialProgressColors: ChewieProgressColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    bufferedColor: Colors.grey,
                    handleColor: Theme.of(context).colorScheme.primary,
                  ),
                );
                setState(() {});
              }
            })
            .catchError((e) {
              if (mounted) {
                setState(() {
                  _error = 'Failed to load video: $e';
                });
              }
            });
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        height: 200,
        color: Colors.grey.shade300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isYoutube && _ytController != null) ...[
          YoutubePlayer(
            controller: _ytController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Theme.of(context).colorScheme.primary,
            onReady: () {
              if (mounted) setState(() {});
            },
            onEnded: (_) {},
          ),
        ] else if (_chewieController != null && _videoController != null) ...[
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
        ] else if (!isYoutube && _videoController == null) ...[
          Container(
            height: 200,
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
        if ((widget.title ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
