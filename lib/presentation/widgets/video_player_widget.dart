import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  // YoutubePlayerController? _ytController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _error;
  bool _isInitializing = true;

  String? _extractYoutubeVideoId(String url) {
    try {
      // Check if it's a placeholder URL
      if (url.contains('example') || url.contains('placeholder')) {
        return null; // Indicate this is a placeholder
      }

      // // Try youtube_player_flutter's built-in method
      // final id = YoutubePlayer.convertUrlToId(url);
      // if (id != null && id.isNotEmpty && !id.contains('example')) return id;

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
    _initializePlayer();
  }

  void _initializePlayer() {
    if (widget.url.isEmpty) {
      setState(() {
        _error = 'No video URL provided';
        _isInitializing = false;
      });
      return;
    }

    // Check for placeholder URLs
    if (widget.url.contains('example') || widget.url.contains('placeholder')) {
      setState(() {
        _error = 'This is a placeholder video URL. Please update the database with real YouTube links.\n\nExample format: https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        _isInitializing = false;
      });
      return;
    }

    if (isYoutube) {
      final videoId = _extractYoutubeVideoId(widget.url);
      if (videoId != null && videoId.isNotEmpty) {
        try {
          // _ytController = YoutubePlayerController(
          //   initialVideoId: videoId,
          //   flags: const YoutubePlayerFlags(
          //     autoPlay: false,
          //     mute: false,
          //     enableCaption: true,
          //   ),
          // );
          // _ytController!.addListener(() {
          //   if (_ytController!.value.isReady) {
          //     setState(() {
          //       _isInitializing = false;
          //     });
          //   }
          // });
          Future.delayed(Duration(seconds: 2), () {
            if (mounted && _isInitializing) {
              setState(() {
                _isInitializing = false;
              });
            }
          });
        } catch (e) {
          setState(() {
            _error = 'Failed to initialize YouTube player: $e';
            _isInitializing = false;
          });
        }
      } else {
        setState(() {
          _error = 'Invalid YouTube URL: Could not extract video ID';
          _isInitializing = false;
        });
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
                setState(() {
                  _isInitializing = false;
                });
              }
            })
            .catchError((e) {
              if (mounted) {
                setState(() {
                  _error = 'Failed to load video: $e';
                  _isInitializing = false;
                });
              }
            });
    }
  }

  @override
  void dispose() {
    // _ytController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Error State - Enhanced UI only
    if (_error != null) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 200,
          maxHeight: 250,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFFFDCFFA).withOpacity(0.1), Color(0xFFD78FEE).withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Color(0xFFD78FEE).withOpacity(0.3)),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFFDCFFA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 32,
                    color: Color(0xFF9B5DE0),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Video Error',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF4E56C0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 60,
                  child: SingleChildScrollView(
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Loading State - Enhanced UI only
    if (_isInitializing) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 200,
          maxHeight: 250,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF252542)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9B5DE0), Color(0xFFD78FEE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD78FEE).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Video...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4E56C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4E56C0).withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // YouTube Player - COMPLETELY UNCHANGED
            // if (isYoutube && _ytController != null) ...[
            //   YoutubePlayer(
            //     controller: _ytController!,
            //     showVideoProgressIndicator: true,
            //     progressIndicatorColor: Theme.of(context).colorScheme.primary,
            //     onReady: () {
            //       if (mounted) setState(() {});
            //     },
            //     onEnded: (_) {},
            //   ),
            // ] 
            
            // else
            // Chewie Player - COMPLETELY UNCHANGED
             if (_chewieController != null && _videoController != null) ...[
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            ] 
            
            // Loading fallback - COMPLETELY UNCHANGED
            else if (!isYoutube && _videoController == null) ...[
              Container(
                height: 200,
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ],
            
            // Enhanced Title Section (only this is updated)
            if ((widget.title ?? '').isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1a1a2e), Color(0xFF252542)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF4E56C0).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD78FEE), Color(0xFFFDCFFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFD78FEE).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              color: Color(0xFF9B5DE0),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 40,
                            ),
                            child: Text(
                              widget.title!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(0xFF4E56C0).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isYoutube ? Icons.play_circle_outline_rounded : Icons.videocam_rounded,
                        color: Color(0xFF9B5DE0),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}