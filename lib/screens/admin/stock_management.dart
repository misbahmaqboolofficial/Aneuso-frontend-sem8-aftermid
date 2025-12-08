import 'package:flutter/material.dart';

class StockManagementScreen extends StatelessWidget {
  const StockManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Add New Product'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (_, index) {
                return Card(
                  color: Colors.grey[800],
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.eco, color: Colors.green[400]),
                    ),
                    title: Text('Fertilizer ${index + 1}', style: const TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock: ${20 + index * 5} kg', style: TextStyle(color: Colors.grey[400])),
                        Text('Rs. ${150 + index * 50}',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Icon(Icons.edit, color: Colors.red[700]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
