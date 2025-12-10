import 'package:flutter/material.dart';
// provider not required here

import '../../services/branch_service.dart';

class BranchStatsScreen extends StatefulWidget {
  const BranchStatsScreen({Key? key}) : super(key: key);

  @override
  State<BranchStatsScreen> createState() => _BranchStatsScreenState();
}

class _BranchStatsScreenState extends State<BranchStatsScreen> {
  final BranchService _service = BranchService();
  bool _loading = true;
  Map<String, dynamic>? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getStatsOverview();
      setState(() => _stats = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // Helper method to get gradient for cards
  LinearGradient _getCardGradient(int index) {
    final gradients = [
      LinearGradient(
        colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF9B5DE0), Color(0xFFD78FEE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFFD78FEE), Color(0xFFFDCFFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF4E56C0), Color(0xFFD78FEE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[index % gradients.length];
  }

  // Helper method to get icon for stats
  IconData _getStatIcon(String key) {
    if (key.toLowerCase().contains('total') || key.toLowerCase().contains('count')) {
      return Icons.summarize;
    } else if (key.toLowerCase().contains('average') || key.toLowerCase().contains('mean')) {
      return Icons.trending_up;
    } else if (key.toLowerCase().contains('revenue') || key.toLowerCase().contains('sales')) {
      return Icons.attach_money;
    } else if (key.toLowerCase().contains('customer') || key.toLowerCase().contains('client')) {
      return Icons.people;
    } else if (key.toLowerCase().contains('growth') || key.toLowerCase().contains('change')) {
      return Icons.show_chart;
    } else if (key.toLowerCase().contains('company')) {
      return Icons.business;
    }
    return Icons.bar_chart;
  }

  // Method to format company data
  Widget _buildCompanyData(String key, dynamic value) {
    try {
      if (key.toLowerCase().contains('company')) {
        if (value is String && value.contains('[{') && value.contains('}]')) {
          // Parse the JSON string
          // final cleanValue = value.replaceAllMapped(
          //   RegExp(r'\[{(.*?)}\]'),
          //   (match) {
          //     final content = match.group(1);
          //     final items = content!.split('}, {');
          //     final companies = items.map((item) {
          //       final cleanItem = item.replaceAll('{', '').replaceAll('}', '');
          //       final pairs = cleanItem.split(', ');
          //       Map<String, String> companyData = {};
          //       for (var pair in pairs) {
          //         final keyValue = pair.split(': ');
          //         if (keyValue.length == 2) {
          //           companyData[keyValue[0].trim()] = keyValue[1].trim();
          //         }
          //       }
          //       return companyData;
          //     }).toList();

          //     return companies.length.toString();
          //   },
          // );

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4E56C0).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '${key.replaceAll('_', ' ').toTitleCase()} IDs',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Show company distribution
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Distribution',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildCompanyDistribution(value),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }
      return _buildRegularStatCard(key, value);
    } catch (e) {
      return _buildRegularStatCard(key, value);
    }
  }

  Widget _buildCompanyDistribution(String jsonData) {
    try {
      // Extract company data from the string
      final regex = RegExp(r'company_id: (\d+), count: (\d+)');
      final matches = regex.allMatches(jsonData);
      
      if (matches.isEmpty) {
        return Text(
          'No company data available',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        );
      }

      final companies = matches.map((match) {
        return {
          'id': match.group(1),
          'count': int.tryParse(match.group(2) ?? '0') ?? 0,
        };
      }).toList();

      // Calculate total count for percentages
      final totalCount = companies.fold(0, (sum, company) => sum + (company['count'] as int));

      return Column(
        children: [
          ...companies.map((company) {
            final count = company['count'] as int;
            final percentage = totalCount > 0 ? (count / totalCount * 100) : 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'C${company['id']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Company ID ${company['id']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '$count ${count == 1 ? 'branch' : 'branches'}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  // Progress bar
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFDCFFA), Color(0xFFD78FEE)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Branches',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$totalCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return Text(
        'Error displaying company data',
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      );
    }
  }

  Widget _buildRegularStatCard(String key, dynamic value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: _getCardGradient(key.hashCode),
        boxShadow: [
          BoxShadow(
            color: _getCardGradient(key.hashCode).colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatIcon(key),
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  key.replaceAll('_', ' ').toTitleCase(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(
          'Branch Statistics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF9B5DE0), Color(0xFFD78FEE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading Statistics...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4E56C0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(0xFFFDCFFA).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Color(0xFF9B5DE0),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _loadStats,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4E56C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'Try Again',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD78FEE).withOpacity(0.1), Color(0xFFFDCFFA).withOpacity(0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(0xFFD78FEE).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.analytics,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Performance Overview',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4E56C0),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Latest statistics and insights',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Stats Grid
                      Expanded(
                        child: _stats != null && _stats!.isNotEmpty
                            ? ListView(
                                children: [
                                  ..._stats!.entries.map((entry) {
                                    final key = entry.key.toString();
                                    final value = entry.value.toString();
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: key.toLowerCase().contains('company')
                                          ? _buildCompanyData(key, value)
                                          : _buildRegularStatCard(key, value),
                                    );
                                  }).toList(),
                                ],
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.bar_chart,
                                      size: 80,
                                      color: Color(0xFFD78FEE).withOpacity(0.5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No statistics available',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Extension for string title case
extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}