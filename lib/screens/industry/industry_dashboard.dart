import 'package:flutter/material.dart';

class IndustryDashboard extends StatelessWidget {
  final String companyName;
  final String email;

  const IndustryDashboard({
    super.key,
    required this.companyName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Industry Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              '🎉 Login Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome, $companyName!',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              'Email: $email',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // We'll add navigation later
              },
              child: const Text('Continue to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}