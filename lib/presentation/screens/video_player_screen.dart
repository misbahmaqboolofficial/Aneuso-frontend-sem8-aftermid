import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String url;
  final String? title;

  const VideoPlayerScreen({Key? key, required this.url, this.title})
    : super(key: key);

  static Route route({required String url, String? title}) {
    return MaterialPageRoute(
      builder: (_) => VideoPlayerScreen(url: url, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Video Player')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: VideoPlayerWidget(url: url, title: title),
            ),
            const SizedBox(height: 10),
            Text(
              title ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
