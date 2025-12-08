// import 'package:flutter/material.dart';
// import '../admin/admin_login_screen.dart';
// import '../driver/driver_login_screen.dart';
// import '../industry/industry_login_screen.dart';
// import '../citizen/citizen_login_screen.dart';

// class UserTypeSelectionScreen extends StatelessWidget {
//   const UserTypeSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4FAF7),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),

//                 // ===== HEADER / LOGO =====
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1C8B5F).withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(22),
//                     border: Border.all(
//                       color: const Color(0xFF1C8B5F).withOpacity(0.25),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.recycling_rounded,
//                         size: 90,
//                         color: const Color(0xFF1C8B5F),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Aneuso',
//                         style: TextStyle(
//                           fontSize: 34,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1C8B5F),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         'A New Surrounding – Waste Management',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: const Color(0xFF1C8B5F).withOpacity(0.9),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         'Gulbahao Environmental Solutions',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF2C3E50),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // ===== TITLE =====
//                 const Text(
//                   'Select Your Role',
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 const Text(
//                   'Choose how you want to use the system',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFF2C3E50),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 35),

//                 // ====== ADMIN ======
//                 _buildUserTypeCard(
//                   context,
//                   color: const Color(0xFFC6922D),
//                   icon: Icons.admin_panel_settings_rounded,
//                   title: "Admin",
//                   subtitle: "System Administrator",
//                   description: "Manage users, approve registrations and oversee the platform.",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const AdminLoginScreen(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // ====== INDUSTRY ======
//                 _buildUserTypeCard(
//                   context,
//                   color: const Color(0xFF1565C0),
//                   icon: Icons.factory_rounded,
//                   title: "Industry",
//                   subtitle: "Business / Factory",
//                   description: "Register your industry and avail waste disposal and recycling services.",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const IndustryLoginScreen(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // ====== DRIVER ======
//                 _buildUserTypeCard(
//                   context,
//                   color: const Color(0xFF2ECC71),
//                   icon: Icons.local_shipping_rounded,
//                   title: "Driver",
//                   subtitle: "Collection Driver",
//                   description: "View assigned routes and daily waste collection tasks.",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DriverLoginScreen(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // ====== CITIZEN ======
//                 _buildUserTypeCard(
//                   context,
//                   color: const Color(0xFFF39C12),
//                   icon: Icons.people_alt_rounded,
//                   title: "Citizen",
//                   subtitle: "General User",
//                   description: "Report waste issues and track collection schedules in your area.",
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const CitizenLoginScreen(),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 35),

//                 // ===== INFO BOX =====
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     border:
//                         Border.all(color: const Color(0xFF1C8B5F).withOpacity(0.25)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       )
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: const [
//                           Icon(Icons.info_outline,
//                               size: 20, color: Color(0xFF1565C0)),
//                           SizedBox(width: 10),
//                           Text(
//                             "Important Information",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF1565C0),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInfoRow("• Admin accounts are pre-created."),
//                       _buildInfoRow("• Drivers require admin approval."),
//                       _buildInfoRow("• Industries can register instantly."),
//                       _buildInfoRow("• Citizens can register instantly."),
//                       _buildInfoRow("• Contact admin for assistance."),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // ===== CONTACT BOX =====
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1C8B5F).withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: const Color(0xFF1C8B5F).withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       const Text(
//                         "Need Help?",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1C8B5F),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         "📧 Email: admin@gulbahao.com",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: const Color(0xFF1C8B5F).withOpacity(0.9),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "🌐 Website: www.gulbahao.com",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: const Color(0xFF1C8B5F).withOpacity(0.9),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ===== USER CARD WIDGET =====
//   Widget _buildUserTypeCard(
//     BuildContext context, {
//     required Color color,
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String description,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       shadowColor: color.withOpacity(0.3),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(22),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(18),
//             gradient: LinearGradient(
//               colors: [
//                 color.withOpacity(0.12),
//                 color.withOpacity(0.05),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: color.withOpacity(0.25),
//                 ),
//                 child: Icon(icon, size: 32, color: color),
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: color,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF2C3E50),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       description,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Color(0xFF2C3E50),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.arrow_forward_ios,
//                   size: 16, color: color.withOpacity(0.8)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 12,
//           color: Color(0xFF2C3E50),
//         ),
//       ),
//     );
//   }
// }
