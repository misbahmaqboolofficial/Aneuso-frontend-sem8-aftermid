import 'package:flutter/material.dart';

class ClientManagementScreen extends StatelessWidget {
  const ClientManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> clients = [
      // Industries
      {
        "name": "Lays (PepsiCo Pakistan)", 
        "type": "Industry", 
        "desc": "Snacks Production", 
        "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Lay%27s_logo_%282018%29.svg/1200px-Lay%27s_logo_%282018%29.svg.png"
      },
      {
        "name": "Engro Corporation", 
        "type": "Industry", 
        "desc": "Fertilizer & Chemicals", 
        "image": "https://www.engro.com/wp-content/uploads/2022/03/Engro-logo.png"
      },
      {
        "name": "Unilever Pakistan", 
        "type": "Industry", 
        "desc": "FMCG", 
        "image": "https://1000logos.net/wp-content/uploads/2017/06/Unilever-Logo.png"
      },
      {
        "name": "Nestlé Pakistan", 
        "type": "Industry", 
        "desc": "Food & Dairy", 
        "image": "https://1000logos.net/wp-content/uploads/2020/05/Nestle-Logo.png"
      },
      {
        "name": "PepsiCo Pakistan", 
        "type": "Industry", 
        "desc": "Beverages & Snacks", 
        "image": "https://1000logos.net/wp-content/uploads/2017/05/Pepsi-logo.png"
      },
      {
        "name": "Fauji Fertilizer", 
        "type": "Industry", 
        "desc": "Fertilizer", 
        "image": "https://www.ffc.com.pk/wp-content/uploads/2021/06/ffc-logo.png"
      },
      {
        "name": "Engro Foods", 
        "type": "Industry", 
        "desc": "Dairy & Food", 
        "image": "https://www.olper.com.pk/wp-content/uploads/2021/06/olper-logo.png"
      },
      {
        "name": "Shezan Juice Ltd.", 
        "type": "Industry", 
        "desc": "Beverages & Food", 
        "image": "https://shezan.com.pk/wp-content/uploads/2021/06/Shezan-Logo.png"
      },
      {
        "name": "Murree Brewery", 
        "type": "Industry", 
        "desc": "Beverage", 
        "image": "https://murreebrewery.com/wp-content/uploads/2021/06/Murree-Brewery-Logo.png"
      },

      // Universities
      {
        "name": "IBA Karachi", 
        "type": "University", 
        "desc": "Business & Economics", 
        "image": "https://www.iba.edu.pk/images/logo.png"
      },
      {
        "name": "LUMS Lahore", 
        "type": "University", 
        "desc": "Management Sciences", 
        "image": "https://lums.edu.pk/themes/lums_theme/images/lums-logo.svg"
      },
      {
        "name": "NUST Islamabad", 
        "type": "University", 
        "desc": "Engineering & Sciences", 
        "image": "https://nust.edu.pk/wp-content/uploads/2021/04/NUST-Logo-1.png"
      },

      // Schools
      {
        "name": "The City School", 
        "type": "School", 
        "desc": "Private Education", 
        "image": "https://www.thecityschool.net/global-images/logo-thecityschool.png"
      },
      {
        "name": "Beaconhouse School System", 
        "type": "School", 
        "desc": "Private Education", 
        "image": "https://www.beaconhouse.net/bss-templates/images/bss_logo.png"
      },
      {
        "name": "Roots International School", 
        "type": "School", 
        "desc": "Private Education", 
        "image": "https://roots.edu.pk/wp-content/uploads/2021/06/roots-logo.png"
      },

      // Hospitals
      {
        "name": "Aga Khan University Hospital", 
        "type": "Hospital", 
        "desc": "Healthcare", 
        "image": "https://www.aku.edu/assets/images/aku-logo.svg"
      },
      {
        "name": "Indus Hospital Karachi", 
        "type": "Hospital", 
        "desc": "Healthcare", 
        "image": "https://www.indushospital.org.pk/assets/images/logo.png"
      },
      {
        "name": "SIUT Karachi", 
        "type": "Hospital", 
        "desc": "Healthcare", 
        "image": "https://www.siut.org/wp-content/uploads/2021/06/siut-logo.png"
      },
    ];

    // Group clients by type
    final Map<String, List<Map<String, String>>> groupedClients = {};
    for (var client in clients) {
      if (!groupedClients.containsKey(client["type"])) {
        groupedClients[client["type"]!] = [];
      }
      groupedClients[client["type"]!]!.add(client);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: groupedClients.entries.map((entry) {
          final type = entry.key;
          final clientsOfType = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: clientsOfType.map((client) {
                  return Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          client["image"]!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[700],
                              child: const Icon(Icons.business, color: Colors.white),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[700],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      title: Text(client["name"]!, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(client["desc"]!, style: TextStyle(color: Colors.grey[400])),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red[700]),
                      onTap: () {
                        // Add navigation or client details functionality here
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}