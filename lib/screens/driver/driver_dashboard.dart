import 'package:flutter/material.dart';

class DriverDashboard extends StatelessWidget {
  final String driverName;
  final String email;
  final String vehicle;

  const DriverDashboard({
    super.key,
    required this.driverName,
    required this.email,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.drive_eta, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              '🚛 Hi Driver!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome, $driverName!',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Vehicle: $vehicle',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // We'll add features later
              },
              child: const Text('View Today\'s Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}