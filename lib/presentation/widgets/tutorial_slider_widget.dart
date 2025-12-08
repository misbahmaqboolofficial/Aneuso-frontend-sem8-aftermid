import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tutorial_provider.dart';

class TutorialSliderWidget extends StatefulWidget {
  const TutorialSliderWidget({Key? key}) : super(key: key);

  @override
  State<TutorialSliderWidget> createState() => _TutorialSliderWidgetState();
}

class _TutorialSliderWidgetState extends State<TutorialSliderWidget> {
  final PageController _controller = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, provider, _) {
        final items = provider.slider;
        if (items.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final entry = items[index];
              final video = entry['video'] ?? entry['Video'] ?? {};
              final title = video['title'] ?? '';
              final link = video['youtube_link'] ?? video['youtubeLink'] ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      if (video['id'] != null) {
                        Navigator.pushNamed(
                          context,
                          '/tutorials/video',
                          arguments: {'id': video['id']},
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            link,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
