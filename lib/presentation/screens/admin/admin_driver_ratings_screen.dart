import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:aneuso_app/presentation/providers/driver_ratings_provider.dart';
import 'package:aneuso_app/presentation/widgets/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('admin_driver_ratings_screen.dart');

class AdminDriverRatingsScreen extends StatefulWidget {
  const AdminDriverRatingsScreen({super.key});

  @override
  State<AdminDriverRatingsScreen> createState() => _AdminDriverRatingsScreenState();
}

class _AdminDriverRatingsScreenState extends State<AdminDriverRatingsScreen> {
  final _search = TextEditingController();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    final p = context.read<DriverRatingsProvider>();
    p.loadAdminAnalytics();
    if (_filter == 'top') {
      p.loadAdminRatings(topDrivers: true);
    } else {
      p.loadAdminRatings(
        lowOnly: _filter == 'low',
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );
    }
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text(
          'Remove this rating permanently. Use for inappropriate content only.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final success = await context.read<DriverRatingsProvider>().deleteRating(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Rating removed.' : 'Delete failed.'),
        backgroundColor: success ? AppColors.primaryDeep : AppColors.error,
      ),
    );
    if (success) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        foregroundColor: Colors.white,
        title: Text(
          _kScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: AppPageBackground(
        child: Consumer<DriverRatingsProvider>(
          builder: (context, p, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _AnalyticsHeader(data: p.adminAnalytics),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: 'Search by company / industry',
                        filled: true,
                        fillColor: AppColors.surface,
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => setState(() => _reload()),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All ratings'),
                          selected: _filter == 'all',
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          onSelected: (_) => setState(() {
                            _filter = 'all';
                            _reload();
                          }),
                        ),
                        ChoiceChip(
                          label: const Text('Low ratings'),
                          selected: _filter == 'low',
                          selectedColor: AppColors.primaryLight.withValues(alpha: 0.4),
                          onSelected: (_) => setState(() {
                            _filter = 'low';
                            _reload();
                          }),
                        ),
                        ChoiceChip(
                          label: const Text('Top drivers'),
                          selected: _filter == 'top',
                          selectedColor: AppColors.accentLight.withValues(alpha: 0.55),
                          onSelected: (_) => setState(() {
                            _filter = 'top';
                            _reload();
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                if (p.adminLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (p.adminError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(p.adminError!, textAlign: TextAlign.center),
                    ),
                  )
                else if (p.adminRows.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 56, color: AppColors.primaryLight),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'top'
                                ? 'No top drivers match yet.'
                                : 'No ratings to display.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final row = p.adminRows[i] as Map<String, dynamic>;
                        return _AdminRatingRow(
                          data: row,
                          isTopMode: _filter == 'top',
                          onDelete: _filter == 'top'
                              ? null
                              : () => _confirmDelete((row['id'] as num).toInt()),
                        );
                      },
                      childCount: p.adminRows.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _fmtAvg(dynamic v) {
  if (v == null) return '—';
  final n = v is num ? v.toDouble() : double.tryParse(v.toString());
  if (n == null) return v.toString();
  return n.toStringAsFixed(2);
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({this.data});

  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    final total = data!['total_ratings'] ?? 0;
    final sysAvg = data!['average_system_rating'];
    final high = data!['highest_rated_driver'] as Map<String, dynamic>?;
    final low = data!['lowest_rated_driver'] as Map<String, dynamic>?;
    final warns = (data!['recent_low_ratings'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderSoft),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surface,
                  AppColors.accentLight.withValues(alpha: 0.25),
                ],
              ),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System overview',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statBox('Total ratings', '$total', AppColors.primaryDeep),
                    const SizedBox(width: 12),
                    _statBox(
                      'Avg rating',
                      sysAvg == null ? '—' : '$sysAvg',
                      AppColors.primary,
                    ),
                  ],
                ),
                if (high != null || low != null) ...[
                  const Divider(height: 24, color: AppColors.border),
                  if (high != null)
                    Text(
                      'Highest: ${high['driver_name']} (${_fmtAvg(high['avg_rating'])})',
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  if (low != null)
                    Text(
                      'Lowest: ${low['driver_name']} (${_fmtAvg(low['avg_rating'])})',
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (warns.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: AppColors.accentLight.withValues(alpha: 0.35),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primaryLight.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.primaryDeep),
                      SizedBox(width: 8),
                      Text(
                        'Low rating alerts',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...warns.take(5).map((w) {
                    final m = w as Map<String, dynamic>;
                    return Text(
                      '• ${m['driver_name']}: ${m['rating']}★ — ${m['company_name']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Widget _statBox(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminRatingRow extends StatelessWidget {
  const _AdminRatingRow({
    required this.data,
    required this.isTopMode,
    this.onDelete,
  });

  final Map<String, dynamic> data;
  final bool isTopMode;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (isTopMode) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: const Icon(Icons.star, color: AppColors.primaryDeep),
          ),
          title: Text(
            data['driver_name']?.toString() ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeep,
            ),
          ),
          subtitle: Text(
            'Avg ${data['avg_rating']} · ${data['ratings_count']} reviews',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final dt = DateTime.tryParse(data['created_at']?.toString() ?? '');
    final dateStr =
        dt != null ? DateFormat('MMM d, yyyy HH:mm').format(dt.toLocal()) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: ListTile(
        title: Text(
          data['driver_name']?.toString() ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDeep,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['company_name']} · $dateStr',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Text(
              'Rating: ${data['rating']} / 5',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            if ((data['review_comment'] ?? '').toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  data['review_comment'].toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
