// import 'package:flutter/material.dart';
// import '../auth/user_type_selection_screen.dart';

// class CitizenDashboard extends StatelessWidget {
//   final String citizenName;
//   final String email;
//   final String address;

//   const CitizenDashboard({
//     super.key,
//     required this.citizenName,
//     required this.email,
//     required this.address,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       body: Column(
//         children: [
//           // Header with gradient
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF059669),
//                   Color(0xFF10B981),
//                 ],
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello,',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                         Text(
//                           citizenName,
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         _buildHeaderIcon(Icons.notifications_outlined, () => _showNotifications(context)),
//                         const SizedBox(width: 12),
//                         _buildHeaderIcon(Icons.logout, () => _logout(context)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 // Stats in ONE ROW - Modern Cards
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _buildModernStatCard('📋', 'Reports', '3', const Color(0xFF10B981), context),
//                       const SizedBox(width: 12),
//                       _buildModernStatCard('✅', 'Resolved', '12', const Color(0xFF3B82F6), context),
//                       const SizedBox(width: 12),
//                       _buildModernStatCard('⏳', 'Pending', '2', const Color(0xFFF59E0B), context),
//                       const SizedBox(width: 12),
//                       _buildModernStatCard('⭐', 'Rating', '4.8', const Color(0xFF8B5CF6), context),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Main Content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Quick Actions',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
                  
//                   // Address Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E293B),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF10B981).withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(Icons.location_on, color: Color(0xFF10B981), size: 20),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Your Address',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white.withOpacity(0.6),
//                                 ),
//                               ),
//                               Text(
//                                 address.length > 35 ? '${address.substring(0, 35)}...' : address,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Modern Grid
//                   Expanded(
//                     child: GridView.count(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 15,
//                       mainAxisSpacing: 15,
//                       childAspectRatio: 1.1,
//                       children: [
//                         _buildModernActionCard(
//                           'Report Issue',
//                           '🚨',
//                           'Report waste problem',
//                           const Color(0xFFEF4444),
//                           () => _reportIssue(context),
//                         ),
//                         _buildModernActionCard(
//                           'Schedule Pickup',
//                           '🗓️',
//                           'Book waste collection',
//                           const Color(0xFF3B82F6),
//                           () => _schedulePickup(context),
//                         ),
//                         _buildModernActionCard(
//                           'Track Request',
//                           '📱',
//                           'Check request status',
//                           const Color(0xFF8B5CF6),
//                           () => _trackRequest(context),
//                         ),
//                         _buildModernActionCard(
//                           'My Reports',
//                           '📋',
//                           'View your reports',
//                           const Color(0xFF10B981),
//                           () => _myReports(context),
//                         ),
//                         _buildModernActionCard(
//                           'Community',
//                           '👥',
//                           'Community alerts',
//                           const Color(0xFFF59E0B),
//                           () => _communityAlerts(context),
//                         ),
//                         _buildModernActionCard(
//                           'Guidelines',
//                           '📚',
//                           'Waste disposal guide',
//                           const Color(0xFF06B6D4),
//                           () => _guidelines(context),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(icon, size: 20, color: Colors.white),
//         onPressed: onTap,
//       ),
//     );
//   }

//   Widget _buildModernStatCard(String emoji, String title, String value, Color color, BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _showPulseAnimation(context, title);
//       },
//       child: Container(
//         width: 120,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFF1E293B),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               emoji,
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.white.withOpacity(0.7),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildModernActionCard(String title, String emoji, String subtitle, Color color, VoidCallback onTap) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       child: Card(
//         color: const Color(0xFF1E293B),
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   color.withOpacity(0.1),
//                   color.withOpacity(0.05),
//                 ],
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     emoji,
//                     style: const TextStyle(fontSize: 20),
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white.withOpacity(0.6),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Action Methods for Citizen
//   void _reportIssue(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF1E293B),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(25),
//           topRight: Radius.circular(25),
//         ),
//       ),
//       builder: (context) => ConstrainedBox(
//         constraints: BoxConstraints(
//           maxHeight: MediaQuery.of(context).size.height * 0.7,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Report Waste Issue',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Help us keep your area clean',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white.withOpacity(0.6),
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               // Issue Types
//               Expanded(
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: [
//                     _buildIssueType('🚮 Overflowing Bin', 'Public bin is full'),
//                     _buildIssueType('🗑️ Missed Collection', 'Regular pickup missed'),
//                     _buildIssueType('🧹 Illegal Dumping', 'Someone dumped waste illegally'),
//                     _buildIssueType('🐕 Animal Issue', 'Animals scattering waste'),
//                     _buildIssueType('💨 Burning Waste', 'Someone burning waste'),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Report Issue'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildIssueType(String title, String description) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFF374151),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0xFF10B981).withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.report, color: Color(0xFF10B981), size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: Colors.grey),
//         ],
//       ),
//     );
//   }

//   void _schedulePickup(BuildContext context) {
//     _showFeatureComingSoon(context, 'Schedule Pickup');
//   }

//   void _trackRequest(BuildContext context) {
//     _showFeatureComingSoon(context, 'Track Request');
//   }

//   void _myReports(BuildContext context) {
//     _showFeatureComingSoon(context, 'My Reports');
//   }

//   void _communityAlerts(BuildContext context) {
//     _showFeatureComingSoon(context, 'Community Alerts');
//   }

//   void _guidelines(BuildContext context) {
//     _showFeatureComingSoon(context, 'Guidelines');
//   }

//   void _showPulseAnimation(BuildContext context, String feature) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$feature details coming soon!'),
//         backgroundColor: const Color(0xFF10B981),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   void _showNotifications(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: const Color(0xFF1E293B),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Notifications',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF374151),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: const Column(
//                   children: [
//                     Icon(Icons.notifications_none, size: 40, color: Colors.grey),
//                     SizedBox(height: 8),
//                     Text(
//                       'No new notifications',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Close'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _logout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: const Color(0xFF1E293B),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.logout, size: 40, color: Colors.red),
//               const SizedBox(height: 16),
//               const Text(
//                 'Logout',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Are you sure you want to logout?',
//                 style: TextStyle(color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: Colors.white,
//                         side: const BorderSide(color: Colors.grey),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (context) => const UserTypeSelectionScreen()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('Logout'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFeatureComingSoon(BuildContext context, String feature) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: const Color(0xFF1E293B),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.rocket_launch, size: 40, color: Color(0xFF10B981)),
//               const SizedBox(height: 16),
//               const Text(
//                 'Coming Soon!',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 '$feature feature is under development',
//                 style: const TextStyle(color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF10B981),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Got it!'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }