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
  // bool _shouldRedirectToLogin = false;

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
      // Use WidgetsBinding to schedule the navigation after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if user is null and we're done initializing
    if (authProvider.currentUser == null && !_isInitializing) {
      // Return empty container while navigation happens
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Still initializing
    if (_isInitializing || authProvider.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.userType} Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.fullName),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                child: Text(user.fullName.isNotEmpty ? user.fullName[0] : ''),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            // Admin-only: Company & Branch Management
            if (user.isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Company Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/companies');
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Product Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin/products');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_tree),
                title: const Text('Branch Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/branches');
                },
              ),
            ],
            // Citizen: browse products
            if (user.isCitizen) ...[
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Products'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/products');
                },
              ),
            ],
            ExpansionTile(
              leading: const Icon(Icons.play_circle_fill),
              title: const Text('Tutorials'),
              children: [
                ListTile(
                  title: const Text('Browse'),
                  subtitle: const Text(
                    'Explore topics, videos and featured content',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/tutorials/home');
                  },
                ),
                const Divider(),
                if (user.isAdmin) ...[
                  ListTile(
                    title: const Text('Manage Topics'),
                    subtitle: const Text(
                      'Create / Update / Delete tutorial topics',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Manage Topics'),
                          content: const Text(
                            'Admin interface to manage topics will be here.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Manage Videos'),
                    subtitle: const Text(
                      'Create / Update / Delete tutorial videos',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Manage Videos'),
                          content: const Text(
                            'Admin interface to manage videos will be here.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Manage Slider'),
                    subtitle: const Text('Arrange featured slider videos'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Manage Slider'),
                          content: const Text(
                            'Admin interface to manage slider will be here.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => authProvider.logout(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.fullName}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${user.email}'),
                    Text('Phone: ${user.phoneNumber}'),
                    Text('User Type: ${user.userType}'),
                    Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dashboard Content based on user type
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
        return const Center(child: Text('Unknown user type'));
    }
  }

  Widget _buildAdminDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _dashboardItem('Users', Icons.people, Colors.blue),
        _dashboardItem('Reports', Icons.analytics, Colors.green),
        _dashboardItem('Product Management', Icons.inventory, Colors.teal, onTap: () {
          Navigator.pushNamed(context, '/admin/products');
        }),
        _dashboardItem('Settings', Icons.settings, Colors.orange),
        _dashboardItem('Logs', Icons.history, Colors.purple),
      ],
    );
  }

  Widget _buildIndustryDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _dashboardItem('Waste Inventory', Icons.inventory, Colors.blue),
        _dashboardItem('Schedule Pickup', Icons.calendar_today, Colors.green),
        _dashboardItem('History', Icons.history, Colors.orange),
        _dashboardItem('Profile', Icons.person, Colors.purple),
      ],
    );
  }

  Widget _buildDriverDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _dashboardItem('My Routes', Icons.route, Colors.blue),
        _dashboardItem('Today\'s Pickups', Icons.checklist, Colors.green),
        _dashboardItem('Vehicle Info', Icons.directions_car, Colors.orange),
        _dashboardItem('Earnings', Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildCitizenDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _dashboardItem('Request Pickup', Icons.schedule, Colors.blue),
        _dashboardItem('My Requests', Icons.list_alt, Colors.green),
        _dashboardItem('Products', Icons.shopping_bag, Colors.orange, onTap: () {
          Navigator.pushNamed(context, '/products');
        }),
        _dashboardItem('Complaints', Icons.feedback, Colors.purple),
      ],
    );
  }

  Widget _dashboardItem(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
