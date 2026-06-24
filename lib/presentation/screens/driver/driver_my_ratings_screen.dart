import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:aneuso_app/presentation/providers/driver_ratings_provider.dart';
import 'package:aneuso_app/presentation/widgets/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('driver_my_ratings_screen.dart');

class DriverMyRatingsScreen extends StatefulWidget {
  const DriverMyRatingsScreen({super.key});

  @override
  State<DriverMyRatingsScreen> createState() => _DriverMyRatingsScreenState();
}

class _DriverMyRatingsScreenState extends State<DriverMyRatingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverRatingsProvider>().loadDriverMe();
    });
  }

  PreferredSizeWidget _brandAppBar({VoidCallback? onRefresh}) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      ),
      foregroundColor: Colors.white,
      title: Text(
        _kScreenTitle,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: onRefresh,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: _brandAppBar(
        onRefresh: () => context.read<DriverRatingsProvider>().loadDriverMe(),
      ),
      body: AppPageBackground(
        child: Consumer<DriverRatingsProvider>(
          builder: (context, p, _) {
            if (p.driverLoading && p.driverBundle == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (p.driverError != null && p.driverBundle == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(p.driverError!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => p.loadDriverMe(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDeep,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final bundle = p.driverBundle;
            if (bundle == null) {
              return const Center(child: Text('No data'));
            }
            final summary =
                bundle['summary'] as Map<String, dynamic>? ?? <String, dynamic>{};
            final reviews = (bundle['reviews'] as List?) ?? [];
            final trends = (bundle['monthly_trends'] as List?) ?? <dynamic>[];
            final analytics =
                bundle['analytics'] as Map<String, dynamic>? ?? {};

            final avg = summary['average_rating'];
            final avgNum = avg == null
                ? null
                : (avg is num ? avg.toDouble() : double.tryParse('$avg'));
            final totalReviews = summary['total_reviews'] ?? 0;
            final completed = summary['completed_pickups'] ?? 0;
            final top = summary['is_top_rated'] == true;

            return RefreshIndicator(
              onRefresh: () => p.loadDriverMe(),
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _SummaryCard(
                        average: avgNum,
                        totalReviews: totalReviews is int
                            ? totalReviews
                            : int.tryParse('$totalReviews') ?? 0,
                        completedPickups: completed is int
                            ? completed
                            : int.tryParse('$completed') ?? 0,
                        showTopBadge: top,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Performance',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: _AnalyticsStrip(
                        positivePct:
                            (analytics['positive_review_percentage'] ?? 0).toString(),
                        totalReviews: totalReviews,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        'Monthly trends',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _TrendsCard(trends: trends)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(
                        'Recent reviews',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ),
                  ),
                  if (reviews.isEmpty)
                    SliverToBoxAdapter(child: _EmptyReviews())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final r = reviews[i] as Map<String, dynamic>;
                          return _ReviewTile(data: r);
                        },
                        childCount: reviews.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.average,
    required this.totalReviews,
    required this.completedPickups,
    required this.showTopBadge,
  });

  final double? average;
  final int totalReviews;
  final int completedPickups;
  final bool showTopBadge;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppColors.welcomeGradient,
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accentLight),
                const SizedBox(width: 8),
                Text(
                  'Rating summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (showTopBadge)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentLight),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Top rated',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  average == null ? '—' : average!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 6),
                  child: Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 32),
                ),
              ],
            ),
            Text(
              'Average from $totalReviews reviews',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _miniStat(Icons.local_shipping_outlined, '$completedPickups',
                    'Completed pickups'),
                const SizedBox(width: 16),
                _miniStat(Icons.reviews_outlined, '$totalReviews', 'Reviews'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _miniStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentLight),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsStrip extends StatelessWidget {
  const _AnalyticsStrip({
    required this.positivePct,
    required this.totalReviews,
  });

  final String positivePct;
  final dynamic totalReviews;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Positive reviews',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$positivePct%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  Text(
                    'Ratings of 4–5 stars',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            CircularProgressIndicator(
              value: (double.tryParse(positivePct) ?? 0) / 100,
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceMuted,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({required this.trends});

  final List<dynamic> trends;

  static const _barColors = [
    AppColors.primaryDeep,
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.accentLight,
  ];

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Not enough data yet for monthly trends.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    double maxAvg = 0.01;
    for (final t in trends) {
      final m = t as Map<String, dynamic>;
      final a = m['avg_rating'];
      final n = a is num ? a.toDouble() : double.tryParse('$a') ?? 0;
      if (n > maxAvg) maxAvg = n;
    }
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: trends.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final m = trends[i] as Map<String, dynamic>;
          final month = (m['month'] ?? '').toString();
          final a = m['avg_rating'];
          final avg = a is num ? a.toDouble() : double.tryParse('$a') ?? 0;
          final h = 80 * (avg / maxAvg);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 36,
                height: h.clamp(8, 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _barColors[i % _barColors.length],
                      _barColors[(i + 1) % _barColors.length],
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                month.length >= 7 ? month.substring(5) : month,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDeep,
                ),
              ),
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final company = (data['company_name'] ?? 'Industry').toString();
    final rating = data['rating'] is int
        ? data['rating'] as int
        : int.tryParse('${data['rating']}') ?? 0;
    final comment = (data['review_comment'] ?? '').toString();
    DateTime? dt;
    final raw = data['created_at']?.toString();
    if (raw != null) dt = DateTime.tryParse(raw);
    final dateStr =
        dt != null ? DateFormat('MMM d, yyyy').format(dt.toLocal()) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    company,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 18,
                      color: i < rating ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            if (dateStr.isNotEmpty)
              Text(
                dateStr,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(comment, style: const TextStyle(height: 1.35)),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.primaryLight),
          const SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDeep,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When industries rate you after completed pickups, feedback will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
