import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/tutorial_provider.dart';
// import '../../../../domain/entities/tutorial_topic_entity.dart';
import '../../../../domain/entities/tutorial_video_entity.dart';
import '../../../../core/utils/youtube_utils.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('tutorials_home_screen.dart');

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
    _sliderController = PageController(viewportFraction: 0.85);
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
      backgroundColor: Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Text(
          _kScreenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
            tooltip: 'Search',
          ),
        ],
      ),
      body: Consumer<TutorialProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Featured Slider
                _buildFeaturedSlider(provider),
                const SizedBox(height: 32),

                // Topics Grid
                _buildTopicsSection(provider),
                const SizedBox(height: 32),

                // Popular Videos
                _buildPopularVideosSection(provider),
                const SizedBox(height: 24),
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
        height: 220,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color(0xFFD78FEE).withOpacity(0.2),
              Color(0xFFFDCFFA).withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Color(0xFFD78FEE).withOpacity(0.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                size: 60,
                color: Color(0xFF9B5DE0).withOpacity(0.5),
              ),
              SizedBox(height: 12),
              Text(
                'No featured videos',
                style: TextStyle(
                  color: Color(0xFF6F38C5).withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'Featured Videos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6F38C5),
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
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

               return AnimatedContainer(
                 duration: Duration(milliseconds: 300),
                 margin: EdgeInsets.symmetric(
                   horizontal: 8,
                   vertical: _currentSlideIndex == index ? 4 : 12,
                 ),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: [
                     BoxShadow(
                       color: Color(0xFF6F38C5).withOpacity(0.15),
                       blurRadius: 15,
                       offset: Offset(0, 6),
                       spreadRadius: 1,
                     ),
                   ],
                 ),
                 child: GestureDetector(
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
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20),
                       gradient: LinearGradient(
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                         colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                       ),
                     ),
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                         // Thumbnail with error handling
                         if (thumbnailUrl.isNotEmpty)
                           Positioned.fill(
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(20),
                               child: Image.network(
                                 thumbnailUrl,
                                 fit: BoxFit.contain,
                                 errorBuilder: (context, error, stackTrace) {
                                   return Container(
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(20),
                                       gradient: LinearGradient(
                                         begin: Alignment.topLeft,
                                         end: Alignment.bottomRight,
                                         colors: [
                                           Color(0xFF6F38C5),
                                           Color(0xFF9B5DE0),
                                         ],
                                       ),
                                     ),
                                     child: Icon(
                                       Icons.video_collection,
                                       size: 50,
                                       color: Colors.white.withOpacity(0.8),
                                     ),
                                   );
                                 },
                               ),
                             ),
                           ),
                         Container(
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(20),
                             gradient: LinearGradient(
                               begin: Alignment.topCenter,
                               end: Alignment.bottomCenter,
                               colors: [
                                 Colors.transparent,
                                 Colors.black.withOpacity(0.65),
                               ],
                             ),
                           ),
                         ),
                         Positioned(
                           top: 12,
                           left: 12,
                           child: Container(
                             padding: EdgeInsets.symmetric(
                               horizontal: 10,
                               vertical: 4,
                             ),
                             decoration: BoxDecoration(
                               color: Color(0xFFFDCFFA).withOpacity(0.9),
                               borderRadius: BorderRadius.circular(15),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(
                                   Icons.play_arrow,
                                   size: 12,
                                   color: Color(0xFF6F38C5),
                                 ),
                                 SizedBox(width: 4),
                                 Text(
                                   'WATCH',
                                   style: TextStyle(
                                     color: Color(0xFF6F38C5),
                                     fontSize: 10,
                                     fontWeight: FontWeight.w700,
                                     letterSpacing: 0.5,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                         Positioned(
                           bottom: 12,
                           left: 15,
                           right: 15,
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 video.title,
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontSize: 15,
                                   fontWeight: FontWeight.w800,
                                   height: 1.2,
                                 ),
                               ),
                               SizedBox(height: 6),
                               Row(
                                 children: [
                                   Container(
                                     padding: EdgeInsets.symmetric(
                                       horizontal: 8,
                                       vertical: 3,
                                     ),
                                     decoration: BoxDecoration(
                                       color: Color(0xFFD78FEE).withOpacity(0.3),
                                       borderRadius: BorderRadius.circular(10),
                                       border: Border.all(
                                         color: Colors.white.withOpacity(0.2),
                                       ),
                                     ),
                                     child: Text(
                                       video.duration ?? '—',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontSize: 10,
                                         fontWeight: FontWeight.w600,
                                       ),
                                     ),
                                   ),
                                   Spacer(),
                                   Container(
                                     width: 32,
                                     height: 32,
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(16),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.black.withOpacity(0.15),
                                           blurRadius: 8,
                                         ),
                                       ],
                                     ),
                                     child: Icon(
                                       Icons.play_arrow_rounded,
                                       color: Color(0xFF6F38C5),
                                       size: 18,
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               );
             },
           ),
         ),
        // Custom slider dots
        SizedBox(height: 20),
        Center(
          child: Wrap(
            spacing: 6,
            children: List.generate(
              sliderVideos.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _currentSlideIndex == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentSlideIndex == index
                      ? Color(0xFF6F38C5)
                      : Color(0xFFD78FEE).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _currentSlideIndex == index
                      ? [
                          BoxShadow(
                            color: Color(0xFF6F38C5).withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Color(0xFFFDCFFA).withOpacity(0.1),
                Color(0xFFD78FEE).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Color(0xFFD78FEE).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.category_rounded,
                size: 60,
                color: Color(0xFF9B5DE0).withOpacity(0.4),
              ),
              SizedBox(height: 12),
              Text(
                'No categories available',
                style: TextStyle(
                  color: Color(0xFF6F38C5).withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6F38C5),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '${topics.length} topics',
                style: TextStyle(
                  color: Color(0xFF9B5DE0),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getCategoryColor(index).withOpacity(0.9),
                        _getCategoryColor(index).withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getCategoryColor(index).withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getCategoryIcon(index),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                topic.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Color(0xFF6F38C5),
      Color(0xFF9B5DE0),
      Color(0xFFD78FEE),
      Color(0xFF6F38C5),
      Color(0xFF9B5DE0),
      Color(0xFFD78FEE),
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(int index) {
    final icons = [
      Icons.code_rounded,
      Icons.design_services_rounded,
      Icons.business_center_rounded,
      Icons.science_rounded,
      Icons.terminal_rounded,
      Icons.analytics_rounded,
    ];
    return icons[index % icons.length];
  }

  Widget _buildPopularVideosSection(TutorialProvider provider) {
    final videos = provider.videos;

    if (videos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Color(0xFFFDCFFA).withOpacity(0.1),
                Color(0xFFD78FEE).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Color(0xFFD78FEE).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: 60,
                color: Color(0xFF9B5DE0).withOpacity(0.4),
              ),
              SizedBox(height: 12),
              Text(
                'No videos available yet',
                style: TextStyle(
                  color: Color(0xFF6F38C5).withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Latest Videos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6F38C5),
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD78FEE), Color(0xFFFDCFFA)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${videos.length} videos',
                  style: TextStyle(
                    color: Color(0xFF6F38C5),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return _buildVideoListItem(context, video, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoListItem(
    BuildContext context,
    TutorialVideoEntity video,
    int index,
  ) {
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFD78FEE).withOpacity(0.12),
              blurRadius: 15,
              offset: Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6F38C5).withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF333333),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFDCFFA).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFF9B5DE0),
                              ),
                              SizedBox(width: 3),
                              Text(
                                video.duration ?? '—',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9B5DE0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6),
                        if ((video.description ?? '').isNotEmpty)
                          Expanded(
                            child: Text(
                              video.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              // Thumbnail
              Container(
                width: 70,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD78FEE), Color(0xFFFDCFFA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD78FEE).withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: thumbnailUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          thumbnailUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD78FEE),
                                    Color(0xFFFDCFFA),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 30,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.play_arrow_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
