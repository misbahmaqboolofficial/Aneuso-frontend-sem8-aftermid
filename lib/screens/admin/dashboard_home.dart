import 'package:flutter/material.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Clients', '47', Icons.business, Colors.red[700]!),
              _buildStatCard('Active Drivers', '12', Icons.directions_car, Colors.orange[700]!),
              _buildStatCard('Today Pickups', '23', Icons.assignment_turned_in, Colors.green[700]!),
              _buildStatCard('Stock Items', '15', Icons.inventory, Colors.blue[700]!),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: [
              _buildActionCard('Manage Clients', Icons.business_center, () {}),
              _buildActionCard('Update Stock', Icons.inventory_2, () {}),
              _buildActionCard('View Reports', Icons.analytics, () {}),
              _buildActionCard('Send Notifications', Icons.notifications_active, () {}),
            ],
          ),

          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String t, String v, IconData i, Color c) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 40, color: c),
            const SizedBox(height: 8),
            Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(t, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String t, IconData i, VoidCallback onTap) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(i, size: 32, color: Colors.red[700]),
              const SizedBox(height: 8),
              Text(t, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            _item('New client registration - ABC Industries', '2 min ago'),
            _item('Pickup completed - XYZ Factory', '15 min ago'),
            _item('Stock updated - Organic Fertilizer', '1 hour ago'),
            _item('New garbage report from citizen', '2 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _item(String a, String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red[700], shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a, style: const TextStyle(color: Colors.white)),
                Text(t, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
