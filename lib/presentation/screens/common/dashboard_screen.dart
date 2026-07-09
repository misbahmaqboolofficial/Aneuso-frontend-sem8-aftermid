//  — search // <name> button|card|drawer item|dashboard card
import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/screen_title_util.dart';

import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_ui.dart';
import '../../../core/utils/storage_util.dart';
import 'notification_inbox_screen.dart';

import '../citizen/special_offers_screen.dart';
import '../admin/admin_offers_screen.dart';
import '../admin/admin_driver_ratings_screen.dart';
import '../driver/driver_my_ratings_screen.dart';

final String _kDashboardTitle = ScreenTitle.fromFile('dashboard_screen.dart');
final String _kNotificationsTitle =
    ScreenTitle.fromFile('notification_inbox_screen.dart');

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitializing = true;
  int _selectedDrawerIndex = 0;
  int _bottomNavIndex = 0;

  void _openDrawer(BuildContext scaffoldContext) {
    if (_bottomNavIndex == 0) {
      setState(() => _selectedDrawerIndex = 0);
    }
    Scaffold.of(scaffoldContext).openDrawer();
  }

  Future<void> _pushFromDrawer(Future<dynamic> Function() push) async {
    Navigator.pop(context);
    await push();
    if (mounted) {
      setState(() => _selectedDrawerIndex = 0);
    }
  }

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

  // ═══════════════════════════════════════════════════════════════════
  // DASHBOARD TITLE — "Admin Dashboard", "Citizen Dashboard", etc.
  // CUT the line that calls this (see body below) and PASTE anywhere
  // in the children: [ ] list. Keep Expanded(...) LAST in that list.
  // To put title back in the top bar: paste into AppBar title: (line ~407)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildDashboardTitle(UserEntity user, AuthProvider auth, bool narrow) {
    return AppGradientText(
      _kDashboardTitle,
      style: TextStyle(
        fontSize: narrow ? 18 : 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildDashboardModeToggle(UserEntity user, AuthProvider auth) {
    if (!auth.canToggleCitizenDashboard(user)) {
      return const SizedBox.shrink();
    }

    final isCitizen = auth.dashboardCitizenMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeToggleChip(
              label: user.userType,
              icon: Icons.work_outline_rounded,
              selected: !isCitizen,
              onTap: () {
                if (isCitizen) {
                  setState(() => _selectedDrawerIndex = 0);
                  auth.setDashboardCitizenMode(false);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildModeToggleChip(
              label: 'Citizen',
              icon: Icons.people_outline_rounded,
              selected: isCitizen,
              onTap: () {
                if (!isCitizen) {
                  setState(() => _selectedDrawerIndex = 0);
                  auth.setDashboardCitizenMode(true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggleChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.buttonGradient : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCitizenDrawerItems(UserEntity user) {
    return [
      // My Cart drawer item
      _buildDrawerItem(20, 'My Cart', Icons.shopping_cart_rounded, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/citizen/mycart'));
      }), // end My Cart drawer item
      // My Orders drawer item
      _buildDrawerItem(21, 'My Orders', Icons.assignment_rounded, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/citizen/myorders'));
      }), // end My Orders drawer item
      // Report Garbage drawer item
      _buildDrawerItem(17, 'Report Garbage', Icons.add_a_photo_rounded, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/citizen/report-garbage'));
      }), // end Report Garbage drawer item
      // Active Campaigns drawer item
      _buildDrawerItem(18, 'Active Campaigns', Icons.campaign_rounded, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/citizen/cleanup-campaigns'));
      }), // end Active Campaigns drawer item
      // Tutorials drawer item
      _buildDrawerItem(19, 'Tutorials', Icons.play_circle_fill_rounded, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/tutorials/home'));
      }), // end Tutorials drawer item
      // Jobs Portal drawer item
      _buildDrawerItem(35, 'Jobs Portal', Icons.work_outline, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/jobs'));
      }), // end Jobs Portal drawer item
      // Browse Products drawer item
      _buildDrawerItem(5, 'Browse Products', Icons.shopping_bag_rounded, false, () {
        _pushFromDrawer(() => Navigator.pushNamed(context, '/products'));
      }), // end Browse Products drawer item
      // Special Offers drawer item
      _buildDrawerItem(30, 'Special Offers', Icons.local_offer_rounded, false, () {
        _pushFromDrawer(() => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpecialOffersScreen()),
        ));
      }), // end Special Offers drawer item
    ];
  }

  List<Widget> _buildProfessionalDrawerItems(UserEntity user) {
    if (user.userTypeId == 4) {
      return [
        // Branch Management drawer item
        _buildDrawerItem(3, 'Branch Management', Icons.account_tree_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/branches'));
        }), // end Branch Management drawer item
        // Cleanup Operations drawer item
        _buildDrawerItem(25, 'Cleanup Operations', Icons.cleaning_services_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/admin/cleanup-dashboard'));
        }), // end Cleanup Operations drawer item
        // Company Management drawer item
        _buildDrawerItem(2, 'Company Management', Icons.business_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/companies'));
        }), // end Company Management drawer item
        // Public Garbage drawer item
        _buildDrawerItem(22, 'Public Garbage', Icons.report_problem_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/garbage-reports'));
        }), // end Public Garbage drawer item
        // Product Management drawer item
        _buildDrawerItem(4, 'Product Management', Icons.inventory_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/admin/products'));
        }), // end Product Management drawer item
        // Special Offers drawer item
        _buildDrawerItem(37, 'Special Offers', Icons.local_offer_rounded, false, () {
          _pushFromDrawer(() => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminOffersScreen()),
          ));
        }), // end Special Offers drawer item
        // Global Deals drawer item
        _buildDrawerItem(23, 'Global Deals', Icons.handshake_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/admin/deals'));
        }), // end Global Deals drawer item
        // All App Pickups drawer item
        _buildDrawerItem(24, 'All App Pickups', Icons.local_shipping_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/admin/all_pickups'));
        }), // end All App Pickups drawer item
        // Driver Ratings drawer item
        _buildDrawerItem(32, 'Driver Ratings', Icons.rate_review_rounded, false, () {
          _pushFromDrawer(() => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDriverRatingsScreen()),
          ));
        }), // end Driver Ratings drawer item
        // Send Notification drawer item
        _buildDrawerItem(33, 'Send Notification', Icons.campaign_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/admin/broadcast'));
        }), // end Send Notification drawer item
      ];
    }
    if (user.userTypeId == 1) {
      return [
        // Schedule Pickups drawer item
        _buildDrawerItem(10, 'Schedule Pickups', Icons.calendar_today_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/industry/schedule_pickup'));
        }), // end Schedule Pickups drawer item
        // Service History drawer item
        _buildDrawerItem(11, 'Service History', Icons.history_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/industry/service_history'));
        }), // end Service History drawer item
        // Industry Deals drawer item
        _buildDrawerItem(12, 'Industry Deals', Icons.handshake_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/industry/create_deal'));
        }), // end Industry Deals drawer item
      ];
    }
    if (user.userTypeId == 2) {
      return [
        // Daily Tasks drawer item
        _buildDrawerItem(14, 'Daily Tasks', Icons.schedule_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/driver/driverdailytasks'));
        }), // end Daily Tasks drawer item
        // Confirm Pickups drawer item
        _buildDrawerItem(15, 'Confirm Pickups', Icons.checklist_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/driver/confirm_pickups'));
        }), // end Confirm Pickups drawer item
        // My Ratings drawer item
        _buildDrawerItem(31, 'My Ratings', Icons.star_rate_rounded, false, () {
          _pushFromDrawer(() => Navigator.pushNamed(context, '/driver/my_ratings'));
        }), // end My Ratings drawer item
      ];
    }
    return [];
  }

  Widget _buildDrawerHeader(UserEntity user) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
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
                  gradient: const LinearGradient(
                    colors: [Colors.white, AppColors.accentLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep,
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: user.isActive ? AppColors.accentLight : Colors.grey,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isActive ? Icons.check_circle : Icons.error,
                  size: 14,
                  color: user.isActive ? AppColors.accentLight : Colors.grey,
                ),
                SizedBox(width: 6),
                Text(
                  user.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.isActive ? AppColors.accentLight : Colors.grey,
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.primaryDeep.withValues(alpha: 0.12),
                  AppColors.primary.withValues(alpha: 0.06),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(color: AppColors.border)
            : null,
      ),
      // drawer ListTile card
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? AppColors.buttonGradient
                : LinearGradient(
                    colors: [
                      AppColors.surfaceMuted,
                      AppColors.lilac.withValues(alpha: 0.5),
                    ],
                  ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.primaryDeep,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryDeep : AppColors.textPrimary,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.buttonGradient,
                ),
              )
            : null,
        onTap: onTap,
      ), // end drawer ListTile card
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null && !_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDeep),
        ),
      );
    }

    if (_isInitializing || authProvider.currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x449B5DE0),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.recycling_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const AppGradientText(
                'Loading Dashboard...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final user = authProvider.currentUser!;
    final narrow = isNarrowPhone(context);
    final pagePadding = pageHorizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldGradientTop,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldGradientTop,
        elevation: 0,
        titleSpacing: narrow ? 0 : null,

        // TOP BAR TITLE — cut next line and paste into body children: [ ] below
        title: _bottomNavIndex == 0
            ? _buildDashboardTitle(user, authProvider, narrow)
            : Text(_kNotificationsTitle),

        centerTitle: true,
        leading: Builder(
          builder: (context) => AppMenuButton(
            compact: narrow,
            onPressed: () => _openDrawer(context),
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Container(
        //       padding: EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         color: Color(0xFF450693).withOpacity(0.1),
        //         shape: BoxShape.circle,
        //       ),
        //       child: Icon(
        //         Icons.notifications_none_rounded,
        //         color: Color(0xFF450693),
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
                  // Dashboard drawer item
                  _buildDrawerItem(
                    0,
                    'Dashboard',
                    Icons.dashboard_rounded,
                    _selectedDrawerIndex == 0 && _bottomNavIndex == 0,
                    () {
                      setState(() {
                        _selectedDrawerIndex = 0;
                        _bottomNavIndex = 0;
                      });
                      Navigator.pop(context);
                    },
                  ), // end Dashboard drawer item
                  // My Profile drawer item
                  _buildDrawerItem(
                    1,
                    'My Profile',
                    Icons.person_rounded,
                    false,
                    () => _pushFromDrawer(
                      () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ), // end My Profile drawer item

                  if (authProvider.canToggleCitizenDashboard(user)) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: _buildDashboardModeToggle(user, authProvider),
                    ),
                  ],

                  ..._buildProfessionalDrawerItems(user).isEmpty
                      ? _buildCitizenDrawerItems(user)
                      : authProvider.showCitizenDashboard
                          ? _buildCitizenDrawerItems(user)
                          : _buildProfessionalDrawerItems(user),

                  // Messages drawer item
                  _buildDrawerItem(36, 'Messages', Icons.chat_bubble_rounded, false, () {
                    _pushFromDrawer(() => Navigator.pushNamed(context, '/messages'));
                  }), // end Messages drawer item

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
                    // Logout button card
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
                    ), // end Logout button card
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceMuted,
                    AppColors.lilac.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Text(
                'ANEUSO v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: AppPageBackground(
        child: _bottomNavIndex == 0 
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                narrow ? 12 : 20,
                pagePadding,
                narrow ? 12 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  AppWelcomeBanner(
                    greeting: 'Welcome back,',
                    name: user.fullName,
                    email: user.email,
                    phone: user.phoneNumber,
                    compact: narrow,
                  ),
                  SizedBox(height: narrow ? 12 : 16),
                  _buildDashboardModeToggle(user, authProvider),
                  SizedBox(height: narrow ? 16 : 24),
                  

                  
                   AppSectionTitle(
                    'Quick Actions',
                    subtitle: 'Everything you need in one place',
                  ),
                  SizedBox(height: narrow ? 6 : 10),




                 


                  //comes at bottom 
                  Expanded(child: _buildDashboardContent(user, authProvider)),
                ],
              ),
            )
          : const NotificationInboxScreen(),
      ),
      bottomNavigationBar: AppBottomNavShell(
        // bottom navigation bar
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
              if (index == 0) _selectedDrawerIndex = 0;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryDeep,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: narrow ? 11 : 12,
          unselectedFontSize: narrow ? 10 : 11,
          selectedLabelStyle: TextStyle(
            fontSize: narrow ? 11 : 12,
            // fontWeight: FontWeight.w700,
            // color: AppColors.primaryDeep,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: narrow ? 10 : 11,
            // fontWeight: FontWeight.w500,
            // color: AppColors.textMuted,
          ),
          iconSize: narrow ? 22 : 24,
          items: [
              BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded, size: narrow ? 22 : 24),
              label: 'Home',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded, size: narrow ? 22 : 24),
              label: narrow ? 'Alerts' : 'Notifications',
            ),
          
           
          ],
        ), // end bottom navigation bar
      ),
    );
  }

  Widget _buildDashboardContent(UserEntity user, AuthProvider auth) {
    return _buildUnifiedDashboard(user, auth);
  }

  Widget _buildUnifiedDashboard(UserEntity user, AuthProvider auth) {
    final List<Widget> cards = [];
    final citizenView = auth.showCitizenDashboard;

    // Messages dashboard card
    cards.add(_dashboardCard('Messages', Icons.chat_bubble_rounded, AppColors.primaryVariant, 'Chat messages', user, auth)); // end Messages dashboard card

    if (citizenView) {
      // Browse Products dashboard card
      cards.add(_dashboardCard('Browse Products', Icons.shopping_bag_rounded, AppColors.accent, 'Browse products', user, auth)); // end Browse Products dashboard card
      // Tutorials dashboard card
      cards.add(_dashboardCard('Tutorials', Icons.play_circle_fill_rounded, AppColors.primaryLight, 'Browse tutorials', user, auth)); // end Tutorials dashboard card
      // Special Offers dashboard card
      cards.add(_dashboardCard('Special Offers', Icons.local_offer_rounded, AppColors.primary, 'Fertilizer Deals', user, auth)); // end Special Offers dashboard card
      // Jobs Portal dashboard card
      cards.add(_dashboardCard('Jobs Portal', Icons.work_outline, AppColors.primaryDeep, 'Browse jobs', user, auth)); // end Jobs Portal dashboard card
      // My Cart dashboard card
      cards.add(_dashboardCard('My Cart', Icons.shopping_cart_rounded, const Color(0xFFFDCFFA), 'View Cart', user, auth)); // end My Cart dashboard card
      // My Orders dashboard card
      cards.add(_dashboardCard('My Orders', Icons.assignment_rounded, const Color(0xFF9B5DE0), 'View Orders', user, auth)); // end My Orders dashboard card
      // Report Waste dashboard card
      cards.add(_dashboardCard('Report Waste', Icons.add_a_photo_rounded, const Color(0xFFA555EC), 'Report garbage', user, auth)); // end Report Waste dashboard card
      // Campaigns dashboard card
      cards.add(_dashboardCard('Campaigns', Icons.campaign_rounded, const Color(0xFF8A39E1), 'Active Cleanups', user, auth)); // end Campaigns dashboard card
    } else if (user.userTypeId == 4) {
      // Cleanup Ops dashboard card
      cards.add(_dashboardCard('Cleanup Ops', Icons.cleaning_services_rounded, const Color(0xFF6F38C5), 'Manage Cleanups', user, auth)); // end Cleanup Ops dashboard card
      // Public Garbage dashboard card
      cards.add(_dashboardCard('Public Garbage', Icons.report_problem_rounded, const Color(0xFFA555EC), 'Public Garbage', user, auth)); // end Public Garbage dashboard card
      // Companies dashboard card
      cards.add(_dashboardCard('Companies', Icons.business_rounded, const Color(0xFF450693), 'Manage Companies', user, auth)); // end Companies dashboard card
      // Branches dashboard card
      cards.add(_dashboardCard('Branches', Icons.account_tree_rounded, const Color(0xFF8A39E1), 'Manage Branches', user, auth)); // end Branches dashboard card
      // Product Mgmt dashboard card
      cards.add(_dashboardCard('Product Mgmt', Icons.inventory_rounded, const Color(0xFFD78FEE), 'Manage Products', user, auth)); // end Product Mgmt dashboard card
      // Special Offers dashboard card
      cards.add(_dashboardCard('Special Offers', Icons.local_offer_rounded, const Color(0xFFFDCFFA), 'Manage special offers', user, auth)); // end Special Offers dashboard card
      // Global Deals dashboard card
      cards.add(_dashboardCard('Global Deals', Icons.handshake_rounded, const Color(0xFF6F38C5), 'Manage All Deals', user, auth)); // end Global Deals dashboard card
      // All App Pickups dashboard card
      cards.add(_dashboardCard('All App Pickups', Icons.local_shipping_rounded, const Color(0xFFA555EC), 'All App Pickups', user, auth)); // end All App Pickups dashboard card
      // Driver ratings dashboard card
      cards.add(_dashboardCard('Driver ratings', Icons.rate_review_rounded, const Color(0xFF450693), 'Manage reviews', user, auth)); // end Driver ratings dashboard card
      // Send Alert dashboard card
      cards.add(_dashboardCard('Send Alert', Icons.campaign_rounded, const Color(0xFF8A39E1), 'Send notification', user, auth)); // end Send Alert dashboard card
    } else if (user.userTypeId == 1) {
      // Schedule dashboard card
      cards.add(_dashboardCard('Schedule', Icons.calendar_today_rounded, const Color(0xFF9B5DE0), 'Pickup schedule', user, auth)); // end Schedule dashboard card
      // History dashboard card
      cards.add(_dashboardCard('History', Icons.history_rounded, const Color(0xFFD78FEE), 'Past pickups', user, auth)); // end History dashboard card
      // Industry Deals dashboard card
      cards.add(_dashboardCard('Industry Deals', Icons.handshake_rounded, const Color(0xFF6F38C5), 'Manage My Deals', user, auth)); // end Industry Deals dashboard card
    } else if (user.userTypeId == 2) {
      // Daily Tasks dashboard card
      cards.add(_dashboardCard('Daily Tasks', Icons.schedule_rounded, const Color(0xFF9B5DE0), 'Daily tasks', user, auth)); // end Daily Tasks dashboard card
      // Confirm Pickups dashboard card
      cards.add(_dashboardCard('Confirm Pickups', Icons.checklist_rounded, const Color(0xFF6F38C5), 'Confirm pickups', user, auth)); // end Confirm Pickups dashboard card
      // My Ratings dashboard card
      cards.add(_dashboardCard('My Ratings', Icons.star_rate_rounded, const Color(0xFF450693), 'Driver reviews', user, auth)); // end My Ratings dashboard card
    }

    final narrow = isNarrowPhone(context);
    final compact = isCompactPhone(context);

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: compact ? 0.88 : (narrow ? 0.92 : 0.85),
        crossAxisSpacing: narrow ? 10 : 15,
        mainAxisSpacing: narrow ? 10 : 15,
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
    UserEntity user,
    AuthProvider auth,
  ) {

    final narrow = isNarrowPhone(context);

    return AppActionTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      compact: narrow,
      onTap: () => _handleDashboardTap(subtitle, user, auth),
    ); // end dashboard quick action card
  }

  void _handleDashboardTap(String subtitle, UserEntity user, AuthProvider auth) {
    if (subtitle == 'Products' || subtitle == 'Browse products') {
          Navigator.pushNamed(context, '/products');
        } else if (subtitle == 'Manage Products') {
          Navigator.pushNamed(context, '/admin/products');
        } else if (subtitle == 'Manage special offers') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminOffersScreen()),
          );
        } else if (subtitle == 'Chat messages') {
          Navigator.pushNamed(context, '/messages');
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
        } else if (subtitle == 'Driver reviews') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DriverMyRatingsScreen()),
          );
        } else if (subtitle == 'Manage reviews') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDriverRatingsScreen()),
          );
        } else if (subtitle == 'Send notification') {
          Navigator.pushNamed(context, '/admin/broadcast');
        } else if (subtitle == 'Browse tutorials') {
          Navigator.pushNamed(context, '/tutorials/home');
        } else if (subtitle == 'Browse jobs') {
          Navigator.pushNamed(context, '/jobs');
        } else if (subtitle == 'Report garbage') {
          Navigator.pushNamed(context, '/citizen/report-garbage');
        } else if (subtitle == 'Public Garbage') {
          Navigator.pushNamed(context, '/garbage-reports');
        } else if (subtitle == 'Manage All Deals') {
          Navigator.pushNamed(context, '/admin/deals');
        } else if (subtitle == 'Manage My Deals') {
          Navigator.pushNamed(context, '/industry/view_deals');
        } else if (subtitle == 'Active Cleanups') {
          Navigator.pushNamed(context, '/citizen/cleanup-campaigns');
        } else if (subtitle == 'Manage Cleanups') {
          Navigator.pushNamed(context, '/admin/cleanup-dashboard');
        } else if (subtitle == 'Review Citizen Reports') {
          Navigator.pushNamed(context, '/garbage-reports');
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
        } else if (subtitle == 'Fertilizer Deals') {
          if (!auth.showCitizenDashboard && user.userTypeId == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminOffersScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SpecialOffersScreen()));
          }
        }

  }

}
