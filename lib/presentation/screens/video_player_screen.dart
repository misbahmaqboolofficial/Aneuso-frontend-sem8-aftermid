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
      appBar: AppBar(title: Text((title ?? '') + " - Video Player")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // makes the whole page scroll instead of overflowing
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Let the player size itself; no Expanded here
                      VideoPlayerWidget(url: url, title: title),
                      const SizedBox(height: 10),
                      if ((title ?? '').isNotEmpty)
                        Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
