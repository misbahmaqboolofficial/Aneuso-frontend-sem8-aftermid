import 'package:flutter/material.dart';
import '../../services/tutorial_service.dart';
import '../../domain/entities/tutorial_video_entity.dart';

class VideoDetailScreen extends StatefulWidget {
  final int videoId;
  const VideoDetailScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final TutorialService _service = TutorialService();
  TutorialVideoEntity? _video;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _video = await _service.getVideo(widget.videoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _video?.title ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Duration: ${_video?.duration ?? '-'}'),
                  const SizedBox(height: 12),
                  Text(_video?.description ?? ''),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final url = _video?.youtubeLink ?? '';
                      if (url.isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          '/tutorials/video/player',
                          arguments: {'url': url, 'title': _video?.title},
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No video URL available'),
                          ),
                        );
                      }
                    },
                    child: const Text('Play Video'),
                  ),
                ],
              ),
            ),
    );
  }
}
