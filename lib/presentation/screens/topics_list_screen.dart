import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tutorial_provider.dart';
import 'topic_detail_screen.dart';
import '../widgets/tutorial_slider_widget.dart';

class TopicsListScreen extends StatefulWidget {
  const TopicsListScreen({Key? key}) : super(key: key);

  @override
  State<TopicsListScreen> createState() => _TopicsListScreenState();
}

class _TopicsListScreenState extends State<TopicsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TutorialProvider>(context, listen: false);
    provider.fetchSlider();
    provider.fetchTopics(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tutorials')),
          body: RefreshIndicator(
            onRefresh: () async => provider.fetchTopics(refresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  TutorialSliderWidget(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search topics...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (q) =>
                          provider.fetchTopics(search: q, refresh: true),
                    ),
                  ),
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.topics.length,
                          itemBuilder: (ctx, idx) {
                            final t = provider.topics[idx];
                            return ListTile(
                              title: Text(t.title),
                              subtitle: t.description != null
                                  ? Text(t.description!)
                                  : null,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TopicDetailScreen(topicId: t.id),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
