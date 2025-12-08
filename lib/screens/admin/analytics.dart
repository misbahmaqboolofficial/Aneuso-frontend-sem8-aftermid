import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Overview',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),

          // Example Cards (replace with your real widgets)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Total Clients: 150'),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Monthly Stock Usage: 240 kg'),
            ),
          ),
          const SizedBox(height: 16),

          // Add more sections here...
        ],
      ),
    );
  }
}
