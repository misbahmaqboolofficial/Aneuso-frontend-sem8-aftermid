import 'dart:async';
import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_util.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitializing = true;
  int _selectedDrawerIndex = 0;
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

                  // Admin-specific items
                  if (user.isAdmin) ...[
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
                    // _buildDrawerItem(
                    //   8,
                    //   'Send Notification',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 8,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 8);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                  ],

                  // Industry-specific items
                  if (user.isIndustry) ...[
                    // _buildDrawerItem(
                    //   9,
                    //   'Biddings',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 9,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 9);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                    _buildDrawerItem(
                      10,
                      'Schedule Pickups',
                      Icons.inventory_rounded,
                      _selectedDrawerIndex == 10,
                      () {
                        setState(() => _selectedDrawerIndex = 10);
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/industry/schedule_pickup',
                        );
                      },
                    ),
                    _buildDrawerItem(
                      11,
                      'Service History',
                      Icons.inventory_rounded,
                      _selectedDrawerIndex == 11,
                      () {
                        setState(() => _selectedDrawerIndex = 11);
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/industry/service_history',
                        );
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
                    // _buildDrawerItem(
                    //   12,
                    //   'Deal Management',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 12,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 12);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   13,
                    //   'Ratings',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 13,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 13);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                  ],

                  // Driver-specific items
                  if (user.isDriver) ...[
                    _buildDrawerItem(
                      14,
                      'Daily Tasks',
                      Icons.schedule_rounded,
                      _selectedDrawerIndex == 14,
                      () {
                        setState(() => _selectedDrawerIndex = 14);
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/driver/driverdailytasks',
                        );
                      },
                    ),

                    _buildDrawerItem(
                      15,
                      'Confirm Pickups',
                      Icons.inventory_rounded,
                      _selectedDrawerIndex == 15,
                      () {
                        setState(() => _selectedDrawerIndex = 15);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/driver/confirm_pickups');
                      },
                    ),

                    // _buildDrawerItem(
                    //   16,
                    //   'Problem Reports',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 16,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 16);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                  ],

                  // Citizen-specific items
                  if (user.isCitizen) ...[
                    _buildDrawerItem(
                      5,
                      'Products',
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
                      Icons.shopping_bag_rounded,
                      _selectedDrawerIndex == 21,
                      () {
                        setState(() => _selectedDrawerIndex = 21);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/citizen/myorders');
                      },
                    ),

                    // Comment one
                    // _buildDrawerItem(
                    //   17,
                    //   'Report Garbage',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 17,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 17);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                    // Comment one end
                    // _buildDrawerItem(
                    //   18,
                    //   'Collected Status',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 18,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 18);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
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

                    // Comment one
                    // _buildDrawerItem(
                    //   20,
                    //   'Fertilizer Catalog',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 20,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 20);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   21,
                    //   'Orders',
                    //   Icons.inventory_rounded,
                    //   _selectedDrawerIndex == 21,
                    //   () {
                    //     setState(() => _selectedDrawerIndex = 21);
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/admin/products');
                    //   },
                    // ),
                    // Comment one end
                  ],
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: Colors.grey[300]),
                  ),
                  SizedBox(height: 20),
                  // _buildDrawerItem(
                  //   7,
                  //   'Settings',
                  //   Icons.settings_rounded,
                  //   _selectedDrawerIndex == 7,
                  //   () {
                  //     setState(() => _selectedDrawerIndex = 7);
                  //     Navigator.pop(context);
                  //   },
                  // ),
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
      body: Padding(
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
            SizedBox(height: 20),

            // Dashboard Content
            Expanded(child: _buildDashboardContent(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(UserEntity user) {
    switch (user.userTypeId) {
      case AppConstants.userTypeAdmin:
        return _buildAdminDashboard();
      case AppConstants.userTypeIndustry:
        return _buildIndustryDashboard();
      case AppConstants.userTypeDriver:
        return _buildDriverDashboard();
      case AppConstants.userTypeCitizen:
        return _buildCitizenDashboard();
      default:
        return Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              'Unknown user type',
              style: TextStyle(fontSize: 16, color: Color(0xFF4E56C0)),
            ),
          ),
        );
    }
  }

  Widget _buildAdminDashboard() {
    final cards = [
      // Comment One
      // _dashboardCard(
      //   'Users',
      //   Icons.people_rounded,
      //   Color(0xFF4E56C0),
      //   'Manage all users',
      // ),
      // _dashboardCard(
      //   'Reports',
      //   Icons.analytics_rounded,
      //   Color(0xFF9B5DE0),
      //   'View analytics',
      // ),
      // Comment One end
      _dashboardCard(
        'Products',
        Icons.inventory_rounded,
        Color(0xFFD78FEE),
        'Manage Products',
      ),
      _dashboardCard(
        'Profile',
        Icons.person_rounded,
        Color(0xFFD78FEE),
        'Manage Profile',
      ),
      _dashboardCard(
        'Companies',
        Icons.business_rounded,
        Color(0xFFD78FEE),
        'Manage Companies',
      ),
      _dashboardCard(
        'Branches',
        Icons.account_tree_rounded,
        Color(0xFFD78FEE),
        'Manage Branches',
      ),
      // _dashboardCard(
      //   'Settings',
      //   Icons.settings_rounded,
      //   Color(0xFFF15BB5),
      //   'System settings',
      // ),
      // _dashboardCard(
      //   'Logs',
      //   Icons.history_rounded,
      //   Color(0xFF00BBF9),
      //   'View activity logs',
      // ),
      // _dashboardCard(
      //   'Support',
      //   Icons.support_agent_rounded,
      //   Color(0xFF00F5D4),
      //   'Help & support',
      // ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildIndustryDashboard() {
    final cards = [
      // _dashboardCard(
      //   'Inventory',
      //   Icons.inventory_rounded,
      //   Color(0xFF4E56C0),
      //   'Waste inventory',
      // ),
      _dashboardCard(
        'Schedule',
        Icons.calendar_today_rounded,
        Color(0xFF9B5DE0),
        'Pickup schedule',
      ),
      _dashboardCard(
        'History',
        Icons.history_rounded,
        Color(0xFFD78FEE),
        'Past pickups',
      ),
      _dashboardCard(
        'Profile',
        Icons.person_rounded,
        Color(0xFFF15BB5),
        'My profile',
      ),
      // _dashboardCard(
      //   'Reports',
      //   Icons.assessment_rounded,
      //   Color(0xFF00BBF9),
      //   'Generate reports',
      // ),
      // _dashboardCard(
      //   'Support',
      //   Icons.support_rounded,
      //   Color(0xFF00F5D4),
      //   'Get help',
      // ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildDriverDashboard() {
    final cards = [
      // _dashboardCard(
      //   'Routes',
      //   Icons.route_rounded,
      //   Color(0xFF4E56C0),
      //   'My routes',
      // ),
      _dashboardCard(
        'Schedule',
        Icons.schedule_rounded,
        Color(0xFF9B5DE0),
        'Daily tasks',
      ),
      // _dashboardCard(
      //   'Vehicle',
      //   Icons.directions_car_rounded,
      //   Color(0xFFD78FEE),
      //   'Vehicle info',
      // ),
      // _dashboardCard(
      //   'Earnings',
      //   Icons.attach_money_rounded,
      //   Color(0xFFF15BB5),
      //   'My earnings',
      // ),
      _dashboardCard(
        'Pickups',
        Icons.checklist_rounded,
        Color(0xFF00BBF9),
        'Confirm pickups',
      ),
      _dashboardCard(
        'Profile',
        Icons.person_rounded,
        Color(0xFF00F5D4),
        'My profile',
      ),
      // _dashboardCard(
      //   'Support',
      //   Icons.help_rounded,
      //   Color(0xFF00F5D4),
      //   'Help center',
      // ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  Widget _buildCitizenDashboard() {
    final cards = [
      // _dashboardCard(
      //   'Request',
      //   Icons.schedule_rounded,
      //   Color(0xFF4E56C0),
      //   'Request pickup',
      // ),
      // _dashboardCard(
      //   'My Requests',
      //   Icons.list_alt_rounded,
      //   Color(0xFF9B5DE0),
      //   'View requests',
      // ),
      _dashboardCard(
        'Products',
        Icons.shopping_bag_rounded,
        Color(0xFFD78FEE),
        'Browse products',
      ),
      _dashboardCard(
        'Tutorials',
        Icons.play_circle_fill_rounded,
        Color(0xFFD78FEE),
        'Browse tutorials',
      ),
      // _dashboardCard(
      //   'Complaints',
      //   Icons.feedback_rounded,
      //   Color(0xFFF15BB5),
      //   'Submit feedback',
      // ),
      // _dashboardCard(
      //   'History',
      //   Icons.history_rounded,
      //   Color(0xFF00BBF9),
      //   'Past activities',
      // ),
      _dashboardCard(
        'Profile',
        Icons.person_rounded,
        Color(0xFF00F5D4),
        'My account',
      ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
        } else if (subtitle == 'Schedule') {
          Navigator.pushNamed(context, '/industry/schedule_pickup');
        } else if (subtitle == 'History') {
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
