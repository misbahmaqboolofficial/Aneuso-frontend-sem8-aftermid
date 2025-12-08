import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tutorial_provider.dart';
// import '../../domain/entities/tutorial_topic_entity.dart';
import '../../domain/entities/tutorial_video_entity.dart';
import '../../core/utils/youtube_utils.dart';

class TutorialsHomeScreen extends StatefulWidget {
  const TutorialsHomeScreen({Key? key}) : super(key: key);

  @override
  State<TutorialsHomeScreen> createState() => _TutorialsHomeScreenState();
}

class _TutorialsHomeScreenState extends State<TutorialsHomeScreen> {
  int _currentSlideIndex = 0;
  late PageController _sliderController;

  @override
  void initState() {
    super.initState();
    _sliderController = PageController();
    // Force fresh data from server
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TutorialProvider>(context, listen: false);
      provider.fetchTopics(refresh: true);
      provider.fetchVideos(refresh: true);
      provider.fetchSlider();
    });
  }

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorials'),
        elevation: 0,
        backgroundColor: Colors.green.shade700,
      ),
      body: Consumer<TutorialProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Slider
                _buildFeaturedSlider(provider),
                const SizedBox(height: 24),

                // Topics Grid
                _buildTopicsSection(provider),
                const SizedBox(height: 24),

                // Popular Videos
                _buildPopularVideosSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSlider(TutorialProvider provider) {
    final sliderVideos = provider.sliderVideos;

    if (sliderVideos.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text('No featured videos')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _sliderController,
            onPageChanged: (index) =>
                setState(() => _currentSlideIndex = index),
            itemCount: sliderVideos.length,
            itemBuilder: (context, index) {
              final video = sliderVideos[index];
              final videoId = YoutubeUtils.extractVideoId(video.youtubeLink);
              final thumbnailUrl = videoId != null
                  ? YoutubeUtils.getThumbnailUrl(videoId)
                  : '';

              return GestureDetector(
                onTap: () {
                  if (video.youtubeLink.isNotEmpty) {
                    Navigator.pushNamed(
                      context,
                      '/tutorials/video/player',
                      arguments: {
                        'url': video.youtubeLink,
                        'title': video.title,
                      },
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.shade700,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Thumbnail with error handling
                      if (thumbnailUrl.isNotEmpty)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.green.shade700,
                                  child: const Icon(
                                    Icons.video_collection,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.play_circle_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video.duration ?? '—',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Slider dots
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                sliderVideos.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentSlideIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentSlideIndex == index
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsSection(TutorialProvider provider) {
    final topics = provider.topics;

    if (topics.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('No topics available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Categories',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/tutorials/topic',
                  arguments: {'id': topic.id},
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade700,
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category, size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            topic.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularVideosSection(TutorialProvider provider) {
    final videos = provider.videos;

    if (videos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('No videos available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Latest Videos',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildVideoListItem(context, video);
          },
        ),
      ],
    );
  }

  Widget _buildVideoListItem(BuildContext context, TutorialVideoEntity video) {
    final videoId = YoutubeUtils.extractVideoId(video.youtubeLink);
    final thumbnailUrl = videoId != null
        ? YoutubeUtils.getThumbnailUrl(videoId)
        : '';

    return GestureDetector(
      onTap: () {
        if (video.youtubeLink.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/tutorials/video/player',
            arguments: {'url': video.youtubeLink, 'title': video.title},
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail with actual YouTube image or fallback
                Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.green.shade700,
                  ),
                  child: thumbnailUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.green.shade700,
                                child: const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 30,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
                const SizedBox(width: 12),
                // Video info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.duration ?? '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if ((video.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          video.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
