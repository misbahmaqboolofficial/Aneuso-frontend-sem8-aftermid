import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/domain/entities/tutorial_topic_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';
import '../common/tutorials/topic_detail_screen.dart';

/// Industry training for Organic / Recyclables / Non-usable waste separation.
class IndustryThreeBinTrainingScreen extends StatefulWidget {
  const IndustryThreeBinTrainingScreen({super.key});

  @override
  State<IndustryThreeBinTrainingScreen> createState() =>
      _IndustryThreeBinTrainingScreenState();
}

class _IndustryThreeBinTrainingScreenState
    extends State<IndustryThreeBinTrainingScreen> {
  static const _threeBinOrder = ['Organic', 'Recyclables', 'Non-usable'];

  static const _binMeta = {
    'Organic': (
      icon: Icons.eco_rounded,
      color: Color(0xFF06D6A0),
      blurb: 'Food scraps, garden waste, and other biodegradable material.',
    ),
    'Recyclables': (
      icon: Icons.recycling_rounded,
      color: Color(0xFF6F38C5),
      blurb: 'Paper, plastic, metal, and glass that can be processed again.',
    ),
    'Non-usable': (
      icon: Icons.delete_outline_rounded,
      color: Color(0xFFFF6B6B),
      blurb: 'Residual waste that cannot be recycled or composted.',
    ),
  };

  final String _kScreenTitle =
      ScreenTitle.fromFile('industry_three_bin_training_screen.dart');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TutorialProvider>(context, listen: false);
      provider.fetchTopics(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Text(_kScreenTitle),
        backgroundColor: const Color(0xFF6F38C5),
        foregroundColor: Colors.white,
      ),
      body: Consumer<TutorialProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.topics.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6F38C5)),
            );
          }

          final topics = <TutorialTopicEntity>[];
          for (final title in _threeBinOrder) {
            for (final topic in provider.topics) {
              if (topic.title.toLowerCase() == title.toLowerCase()) {
                topics.add(topic);
                break;
              }
            }
          }

          return RefreshIndicator(
            color: const Color(0xFF6F38C5),
            onRefresh: () => provider.fetchTopics(refresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  'Learn how to separate waste into the three industry bins before pickup.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 20),
                if (topics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Training modules are not available yet.\nPull to refresh.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...topics.map((topic) {
                    final meta = _binMeta[topic.title] ??
                        (
                          icon: Icons.school_rounded,
                          color: const Color(0xFF9B5DE0),
                          blurb: topic.description ?? 'Open training videos.',
                        );
                    return _buildBinCard(context, topic, meta);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBinCard(
    BuildContext context,
    TutorialTopicEntity topic,
    ({IconData icon, Color color, String blurb}) meta,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: meta.color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicDetailScreen(topicId: topic.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(meta.icon, color: meta.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meta.blurb,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: meta.color),
            ],
          ),
        ),
      ),
    );
  }
}
