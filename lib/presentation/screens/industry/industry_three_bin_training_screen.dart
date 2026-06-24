import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('industry_three_bin_training_screen.dart');

/// Industry-only training for Organic / Recyclables / Non-usable waste separation.
class IndustryThreeBinTrainingScreen extends StatefulWidget {
  const IndustryThreeBinTrainingScreen({super.key});

  @override
  State<IndustryThreeBinTrainingScreen> createState() =>
      _IndustryThreeBinTrainingScreenState();
}

class _IndustryThreeBinTrainingScreenState
    extends State<IndustryThreeBinTrainingScreen> {
  static const _threeBinTitles = {'Organic', 'Recyclables', 'Non-usable'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TutorialProvider>(context, listen: false);
      provider.fetchTopics(refresh: true);
      provider.fetchVideos(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Text(
          _kScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
            ),
          ),
        ),
      ),
      body: Consumer<TutorialProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final topics = provider.topics
              .where((t) => _threeBinTitles.contains(t.title))
              .toList();

          if (topics.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '3-bin training videos are loading. Topics: Organic, Recyclables, and Non-usable.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF9B5DE0).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Learn how to separate waste into three bins before pickup. '
                  'Watch each module below — Organic, Recyclables, and Non-usable.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              ...topics.map((topic) {
                final videos = provider.videos
                    .where((v) => v.topicId == topic.id && v.isActive)
                    .toList();
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6F38C5).withValues(alpha: 0.12),
                      child: const Icon(Icons.delete_outline, color: Color(0xFF6F38C5)),
                    ),
                    title: Text(
                      topic.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(topic.description ?? 'Separation guide'),
                    children: videos.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No videos for this bin yet.'),
                            ),
                          ]
                        : videos
                            .map(
                              (video) => ListTile(
                                leading: const Icon(Icons.play_circle_fill,
                                    color: Color(0xFF6F38C5)),
                                title: Text(video.title),
                                subtitle: Text(video.description ?? ''),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/tutorials/video',
                                    arguments: {'id': video.id},
                                  );
                                },
                              ),
                            )
                            .toList(),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
