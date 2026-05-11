import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aneuso_app/core/utils/local_notification_service.dart';
import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_util.dart';
import 'notification_inbox_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitializing = true;
  int _selectedDrawerIndex = 0;
  int _bottomNavIndex = 0;
  StreamSubscription? _notificationSubscription;
  // final List<String> _drawerTitles = [
  //   'Dashboard',
  //   'My Profile',
  //   'Products',
  //   'Tutorials',
  //   'Settings'
  // ];

  @override
  void initState() {
    super.initState();
    _clearStoredCredentials();
    _setupRealtimeNotifications();
  }

  String? _lastRealtimeNotificationId;

  void _setupRealtimeNotifications() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      debugPrint('Supabase Realtime: No user found, skipping listener.');
      return;
    }

    debugPrint('Supabase Realtime: Setting up listener for User ID: ${user.id}');

    _notificationSubscription = Supabase.instance.client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', user.id)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            final latest = data.last; 
            final String currentId = latest['id'].toString();

            // Only show if it's a new ID
            if (_lastRealtimeNotificationId != currentId) {
              _lastRealtimeNotificationId = currentId;
              debugPrint('Supabase Realtime: New event received - ${latest['title']}');
              _showLocalNotification(latest);
            }
          }
        }, onError: (error) {
          debugPrint('Supabase Realtime Error: $error');
        });
  }

  void _showLocalNotification(Map<String, dynamic> notification) {
    LocalNotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: notification['title'] ?? 'New Notification',
      body: notification['body'] ?? '',
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _clearStoredCredentials() async {
    try {
      await StorageUtil.removeStringData("email");
      await StorageUtil.removeStringData("password");
      await StorageUtil.removeStringData("temp_user");
    } catch (e) {
      print("Error clearing stored credentials: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null && !_isInitializing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  Widget _buildDrawerHeader(UserEntity user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0), Color(0xFFD78FEE)],
        ),
      ),
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFFDCFFA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4E56C0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // Status Chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.isActive
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.isActive ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isActive ? Icons.check_circle : Icons.error,
                  size: 14,
                  color: user.isActive ? Colors.green : Colors.red,
                ),
                SizedBox(width: 6),
                Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    int index,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Color(0xFF4E56C0).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? Color(0xFF4E56C0)
                : Colors.grey.withOpacity(0.2),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Color(0xFF4E56C0),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Color(0xFF4E56C0) : Colors.black87,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4E56C0),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null && !_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4E56C0)),
        ),
      );
    }

    if (_isInitializing || authProvider.currentUser == null) {
      return Scaffold(
        backgroundColor: Color(0xFFFDCFFA).withOpacity(0.1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.recycling_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Loading Dashboard...',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF4E56C0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final user = authProvider.currentUser!;

    return Scaffold(
      backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
            ).createShader(bounds);
          },
          child: Text(
            '${user.userType} Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4E56C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_rounded, color: Color(0xFF4E56C0)),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Container(
        //       padding: EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         color: Color(0xFF4E56C0).withOpacity(0.1),
        //         shape: BoxShape.circle,
        //       ),
        //       child: Icon(
        //         Icons.notifications_none_rounded,
        //         color: Color(0xFF4E56C0),
        //         size: 22,
        //       ),
        //     ),
        //     onPressed: () {},
        //   ),
        //   SizedBox(width: 8),
        // ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(user),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    0,
                    'Dashboard',
                    Icons.dashboard_rounded,
                    _selectedDrawerIndex == 0,
                    () {
                      setState(() => _selectedDrawerIndex = 0);
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    1,
                    'My Profile',
                    Icons.person_rounded,
                    _selectedDrawerIndex == 1,
                    () {
                      setState(() => _selectedDrawerIndex = 1);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildDrawerItem(
                    22,
                    'Public Garbage',
                    Icons.report_problem_rounded,
                    _selectedDrawerIndex == 22,
                    () {
                      setState(() => _selectedDrawerIndex = 22);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/garbage-reports');
                    },
                  ),
                  _buildDrawerItem(
                    25,
                    'Cleanup Operations',
                    Icons.cleaning_services_rounded,
                    _selectedDrawerIndex == 25,
                    () {
                      setState(() => _selectedDrawerIndex = 25);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin/cleanup-dashboard');
                    },
                  ),
                  _buildDrawerItem(
                    2,
                    'Company Management',
                    Icons.business_rounded,
                    _selectedDrawerIndex == 2,
                    () {
                      setState(() => _selectedDrawerIndex = 2);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/companies');
                    },
                  ),
                  _buildDrawerItem(
                    3,
                    'Branch Management',
                    Icons.account_tree_rounded,
                    _selectedDrawerIndex == 3,
                    () {
                      setState(() => _selectedDrawerIndex = 3);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/branches');
                    },
                  ),
                  _buildDrawerItem(
                    4,
                    'Product Management',
                    Icons.inventory_rounded,
                    _selectedDrawerIndex == 4,
                    () {
                      setState(() => _selectedDrawerIndex = 4);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin/products');
                    },
                  ),
                  _buildDrawerItem(
                    23,
                    'Global Deals',
                    Icons.handshake_rounded,
                    _selectedDrawerIndex == 23,
                    () {
                      setState(() => _selectedDrawerIndex = 23);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin/deals');
                    },
                  ),
                  _buildDrawerItem(
                    24,
                    'All App Pickups',
                    Icons.local_shipping_rounded,
                    _selectedDrawerIndex == 24,
                    () {
                      setState(() => _selectedDrawerIndex = 24);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin/all_pickups');
                    },
                  ),
                  _buildDrawerItem(
                    10,
                    'Schedule Pickups',
                    Icons.calendar_today_rounded,
                    _selectedDrawerIndex == 10,
                    () {
                      setState(() => _selectedDrawerIndex = 10);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/industry/schedule_pickup');
                    },
                  ),
                  _buildDrawerItem(
                    11,
                    'Service History',
                    Icons.history_rounded,
                    _selectedDrawerIndex == 11,
                    () {
                      setState(() => _selectedDrawerIndex = 11);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/industry/service_history');
                    },
                  ),
                  _buildDrawerItem(
                    12,
                    'Industry Deals',
                    Icons.handshake_rounded,
                    _selectedDrawerIndex == 12,
                    () {
                      setState(() => _selectedDrawerIndex = 12);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/industry/create_deal');
                    },
                  ),
                  _buildDrawerItem(
                    14,
                    'Daily Tasks',
                    Icons.schedule_rounded,
                    _selectedDrawerIndex == 14,
                    () {
                      setState(() => _selectedDrawerIndex = 14);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/driver/driverdailytasks');
                    },
                  ),
                  _buildDrawerItem(
                    15,
                    'Confirm Pickups',
                    Icons.checklist_rounded,
                    _selectedDrawerIndex == 15,
                    () {
                      setState(() => _selectedDrawerIndex = 15);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/driver/confirm_pickups');
                    },
                  ),
                  _buildDrawerItem(
                    5,
                    'Browse Products',
                    Icons.shopping_bag_rounded,
                    _selectedDrawerIndex == 5,
                    () {
                      setState(() => _selectedDrawerIndex = 5);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/products');
                    },
                  ),
                  _buildDrawerItem(
                    20,
                    'My Cart',
                    Icons.shopping_cart_rounded,
                    _selectedDrawerIndex == 20,
                    () {
                      setState(() => _selectedDrawerIndex = 20);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/citizen/mycart');
                    },
                  ),
                  _buildDrawerItem(
                    21,
                    'My Orders',
                    Icons.assignment_rounded,
                    _selectedDrawerIndex == 21,
                    () {
                      setState(() => _selectedDrawerIndex = 21);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/citizen/myorders');
                    },
                  ),
                  _buildDrawerItem(
                    17,
                    'Report Garbage',
                    Icons.add_a_photo_rounded,
                    _selectedDrawerIndex == 17,
                    () {
                      setState(() => _selectedDrawerIndex = 17);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/citizen/report-garbage');
                    },
                  ),
                  _buildDrawerItem(
                    19,
                    'Tutorials',
                    Icons.play_circle_fill_rounded,
                    _selectedDrawerIndex == 19,
                    () {
                      setState(() => _selectedDrawerIndex = 19);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tutorials/home');
                    },
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Colors.grey[300]),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFD78FEE).withOpacity(0.1),
                          Color(0xFFFDCFFA).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFD78FEE).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () => authProvider.logout(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.grey[50],
              child: Text(
                'ANEUSO v1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
      body: _bottomNavIndex == 0 
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card with gradient
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4E56C0).withOpacity(0.9),
                        Color(0xFF9B5DE0).withOpacity(0.9),
                        Color(0xFFD78FEE).withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4E56C0).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              user.fullName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  user.phoneNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.recycling_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // Dashboard title
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E56C0),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Dashboard Content
                Expanded(child: _buildDashboardContent(user)),
              ],
            ),
          )
        : const NotificationInboxScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        selectedItemColor: Color(0xFF4E56C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(UserEntity user) {
    return _buildUnifiedDashboard(user);
  }

  Widget _buildUnifiedDashboard(UserEntity user) {
    final List<Widget> cards = [
      _dashboardCard('Profile', Icons.person_rounded, const Color(0xFF00F5D4), 'My profile'),
      _dashboardCard('Cleanup Ops', Icons.cleaning_services_rounded, const Color(0xFF00BBF9), 'Manage Cleanups'),
      _dashboardCard('Public Garbage', Icons.report_problem_rounded, const Color(0xFFF15BB5), 'Public Garbage'),
      _dashboardCard('Companies', Icons.business_rounded, const Color(0xFF4E56C0), 'Manage Companies'),
      _dashboardCard('Branches', Icons.account_tree_rounded, const Color(0xFF9B5DE0), 'Manage Branches'),
      _dashboardCard('Product Mgmt', Icons.inventory_rounded, const Color(0xFFD78FEE), 'Manage Products'),
      _dashboardCard('Browse Products', Icons.shopping_bag_rounded, const Color(0xFFD78FEE), 'Browse products'),
      _dashboardCard('Global Deals', Icons.handshake_rounded, const Color(0xFF00BBF9), 'Manage All Deals'),
      _dashboardCard('Industry Deals', Icons.handshake_rounded, const Color(0xFF00F5D4), 'Manage My Deals'),
      _dashboardCard('All App Pickups', Icons.local_shipping_rounded, const Color(0xFFF15BB5), 'All App Pickups'),
      _dashboardCard('Schedule', Icons.calendar_today_rounded, const Color(0xFF9B5DE0), 'Pickup schedule'),
      _dashboardCard('History', Icons.history_rounded, const Color(0xFFD78FEE), 'Past pickups'),
      _dashboardCard('Daily Tasks', Icons.schedule_rounded, const Color(0xFF9B5DE0), 'Daily tasks'),
      _dashboardCard('Confirm Pickups', Icons.checklist_rounded, const Color(0xFF00BBF9), 'Confirm pickups'),
      _dashboardCard('My Cart', Icons.shopping_cart_rounded, const Color(0xFFFDCFFA), 'View Cart'),
      _dashboardCard('My Orders', Icons.assignment_rounded, const Color(0xFF9B5DE0), 'View Orders'),
      _dashboardCard('Report Waste', Icons.add_a_photo_rounded, const Color(0xFFF15BB5), 'Report garbage'),
      _dashboardCard('Tutorials', Icons.play_circle_fill_rounded, const Color(0xFFD78FEE), 'Browse tutorials'),
      _dashboardCard('Campaigns', Icons.campaign_rounded, const Color(0xFF9B5DE0), 'Active Cleanups'),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _dashboardCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () {
        // Handle card tap based on title
        if (subtitle == 'Products' || subtitle == 'Browse products') {
          Navigator.pushNamed(context, '/products');
        } else if (subtitle == 'Manage Products') {
          Navigator.pushNamed(context, '/admin/products');
        } else if (subtitle == 'Pickup schedule') {
          Navigator.pushNamed(context, '/industry/schedule_pickup');
        } else if (subtitle == 'Past pickups') {
          Navigator.pushNamed(context, '/industry/service_history');
        } else if (subtitle == 'My profile' ||
            subtitle == 'My account' ||
            subtitle.toLowerCase() == 'MANAge Profile'.toLowerCase()) {
          Navigator.pushNamed(context, '/profile');
        } else if (subtitle == 'Manage Companies') {
          Navigator.pushNamed(context, '/companies');
        } else if (subtitle == 'Manage Branches') {
          Navigator.pushNamed(context, '/branches');
        } else if (subtitle == 'Daily tasks') {
          Navigator.pushNamed(context, '/driver/driverdailytasks');
        } else if (subtitle == 'Confirm pickups') {
          Navigator.pushNamed(context, '/driver/confirm_pickups');
        } else if (subtitle == 'Browse tutorials') {
          Navigator.pushNamed(context, '/tutorials/home');
        } else if (subtitle == 'Report garbage') {
          Navigator.pushNamed(context, '/citizen/report-garbage');
        } else if (subtitle == 'Public Garbage') {
          Navigator.pushNamed(context, '/garbage-reports');
        } else if (subtitle == 'Manage All Deals') {
          Navigator.pushNamed(context, '/admin/deals');
        } else if (subtitle == 'Manage My Deals') {
          Navigator.pushNamed(context, '/industry/create_deal');
        } else if (subtitle == 'Active Cleanups') {
          Navigator.pushNamed(context, '/citizen/cleanup-campaigns');
        } else if (subtitle == 'Manage Cleanups') {
          Navigator.pushNamed(context, '/admin/cleanup-dashboard');
        } else if (subtitle == 'Review Citizen Reports') {
          Navigator.pushNamed(context, '/garbage-reports');
        } else if (subtitle == 'Cleanup missions') {
          Navigator.pushNamed(context, '/driver/cleanup-missions');
        } else if (subtitle == 'All App Pickups') {
          Navigator.pushNamed(context, '/admin/all_pickups');
        } else if (subtitle == 'View Cart') {
          Navigator.pushNamed(context, '/citizen/mycart');
        } else if (subtitle == 'View Orders') {
          Navigator.pushNamed(context, '/citizen/myorders');
        } else if (subtitle == 'Manage all users') {
          // Navigator.pushNamed(context, '/admin/users');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Management coming soon!')));
        } else if (subtitle == 'View analytics') {
          // Navigator.pushNamed(context, '/admin/reports');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analytics coming soon!')));
        } else if (subtitle == 'System settings') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings coming soon!')));
        } else if (subtitle == 'View activity logs') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs coming soon!')));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: Colors.white, size: 24)),
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4E56C0),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
