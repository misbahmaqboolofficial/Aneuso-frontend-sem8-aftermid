  Widget _buildAdminDashboard() {
    final cards = [
      _dashboardCard(
        'Users',
        Icons.people_rounded,
        const Color(0xFF4E56C0),
        'Manage all users',
      ),
      _dashboardCard(
        'Reports',
        Icons.analytics_rounded,
        const Color(0xFF9B5DE0),
        'View analytics',
      ),
      _dashboardCard(
        'Products',
        Icons.inventory_rounded,
        const Color(0xFFD78FEE),
        'Manage Products',
      ),
      _dashboardCard(
        'Profile',
        Icons.person_rounded,
        const Color(0xFFD78FEE),
        'Manage Profile',
      ),
      _dashboardCard(
        'Companies',
        Icons.business_rounded,
        const Color(0xFFD78FEE),
        'Manage Companies',
      ),
      _dashboardCard(
        'Branches',
        Icons.account_tree_rounded,
        const Color(0xFFD78FEE),
        'Manage Branches',
      ),
      _dashboardCard(
        'Deals',
        Icons.handshake_rounded,
        const Color(0xFF00BBF9),
        'Manage All Deals',
      ),
      _dashboardCard(
        'Cleanup Ops',
        Icons.cleaning_services_rounded,
        const Color(0xFF00F5D4),
        'Manage Cleanups',
      ),
      _dashboardCard(
        'All Pickups',
        Icons.list_alt_rounded,
        const Color(0xFFF15BB5),
        'All App Pickups',
      ),
      _dashboardCard(
        'Settings',
        Icons.settings_rounded,
        const Color(0xFFF15BB5),
        'System settings',
      ),
      _dashboardCard(
        'Logs',
        Icons.history_rounded,
        const Color(0xFF00BBF9),
        'View activity logs',
      ),
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
