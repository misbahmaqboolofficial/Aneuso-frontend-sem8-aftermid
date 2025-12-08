import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tutorial_provider.dart';
import 'video_detail_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final int topicId;
  const TopicDetailScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TutorialProvider>(context, listen: false);
    provider.fetchVideos(topicId: widget.topicId, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Topic Videos')),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: provider.videos.length,
                  itemBuilder: (ctx, idx) {
                    final v = provider.videos[idx];
                    return ListTile(
                      title: Text(v.title),
                      subtitle: Text(v.duration ?? ''),
                      trailing: v.isActive
                          ? null
                          : const Text(
                              'Inactive',
                              style: TextStyle(color: Colors.red),
                            ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoDetailScreen(videoId: v.id),
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
