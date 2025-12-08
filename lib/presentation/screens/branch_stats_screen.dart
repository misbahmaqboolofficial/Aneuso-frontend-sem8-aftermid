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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branch Stats')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...(_stats != null
                      ? _stats!.entries.map(
                          (e) => Card(
                            child: ListTile(
                              title: Text(e.key.toString()),
                              trailing: Text(e.value.toString()),
                            ),
                          ),
                        )
                      : []),
                ],
              ),
            ),
    );
  }
}
