import 'dart:io';
import 'dart:ui' as ui;

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/theme/app_theme.dart';
import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';
import 'package:aneuso_app/presentation/providers/auth_provider.dart';
import 'package:aneuso_app/presentation/providers/branch_provider.dart';
import 'package:aneuso_app/presentation/providers/company_provider.dart';
import 'package:aneuso_app/presentation/providers/driver_ratings_provider.dart';
import 'package:aneuso_app/presentation/providers/job_provider.dart';
import 'package:aneuso_app/presentation/providers/tutorial_provider.dart';
import 'package:aneuso_app/presentation/screens/admin/admin_broadcast_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/admin_deals_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/admin_driver_ratings_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/admin_pickups_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/admin_products_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/AdminCleanupDashboard.dart';
import 'package:aneuso_app/presentation/screens/admin/product_form_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/branch_list_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/branch_stats_screen.dart';
import 'package:aneuso_app/presentation/screens/chat/messages_hub_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/cart_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/CleanupCampaignsScreen.dart';
import 'package:aneuso_app/presentation/screens/citizen/orders_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/report_garbage_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/company_list_screen.dart';
import 'package:aneuso_app/presentation/screens/common/dashboard_screen.dart';
import 'package:aneuso_app/presentation/screens/driver/ConfirmPickupsScreen.dart';
import 'package:aneuso_app/presentation/screens/driver/DailyTasksScreen.dart';
import 'package:aneuso_app/presentation/screens/driver/driver_my_ratings_screen.dart';
import 'package:aneuso_app/presentation/screens/driver/DriverMissionScreen.dart';
import 'package:aneuso_app/presentation/screens/industry/create_deal_screen.dart';
import 'package:aneuso_app/presentation/screens/industry/industry_three_bin_training_screen.dart';
import 'package:aneuso_app/presentation/screens/industry/schedule_pickup.dart';
import 'package:aneuso_app/presentation/screens/industry/ServiceHistoryScreen.dart';
import 'package:aneuso_app/presentation/screens/common/jobs/jobs_list_screen.dart';
import 'package:aneuso_app/presentation/screens/common/live_tracking_screen.dart';
import 'package:aneuso_app/presentation/screens/auth/login_screen.dart';
import 'package:aneuso_app/presentation/screens/common/notification_inbox_screen.dart';
import 'package:aneuso_app/presentation/screens/auth/otp_verification_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/products_screen.dart';
import 'package:aneuso_app/presentation/screens/common/profile_screen.dart';
import 'package:aneuso_app/presentation/screens/admin/public_garbage_reports_screen.dart';
import 'package:aneuso_app/presentation/screens/auth/register_screen.dart';
import 'package:aneuso_app/presentation/screens/common/tutorials/topics_list_screen.dart';
import 'package:aneuso_app/presentation/screens/common/tutorials/tutorials_home_screen.dart';
import 'package:aneuso_app/presentation/widgets/app_ui.dart';
import 'package:aneuso_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:path/path.dart' as p;

UserEntity _user(int typeId, {int id = 1, String name = 'Test User'}) {
  return UserEntity(
    id: id,
    fullName: name,
    email: 'test@aneuso.com',
    phoneNumber: '+923001234567',
    userTypeId: typeId,
    activeStatus: 1,
    emailVerifiedAt: DateTime(2025, 1, 1),
    driverId: typeId == AppConstants.userTypeDriver ? 1 : null,
    industryName: typeId == AppConstants.userTypeIndustry ? 'Test Industry' : null,
  );
}

Widget _wrap(
  Widget child, {
  UserEntity? user,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) {
          final p = AuthProvider(AuthService());
          if (user != null) {
            p.setTestUser(user);
          }
          return p;
        },
      ),
      ChangeNotifierProvider(create: (_) => CompanyProvider()),
      ChangeNotifierProvider(create: (_) => BranchProvider()),
      ChangeNotifierProvider(create: (_) => TutorialProvider()),
      ChangeNotifierProvider(create: (_) => AdminProductProvider()),
      ChangeNotifierProvider(create: (_) => DriverRatingsProvider()),
      ChangeNotifierProvider(create: (_) => JobProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      builder: (context, c) => AppResponsiveScope(child: c ?? const SizedBox.shrink()),
      home: RepaintBoundary(key: const Key('screen_shot'), child: child),
    ),
  );
}

Directory _screenshotDir() {
  final root = Directory.current.path.endsWith('test')
      ? Directory.current.parent
      : Directory.current;
  final dir = Directory(p.join(root.path, 'test', 'screenshots'));
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return dir;
}

Future<void> _capture(WidgetTester tester, String name, Widget widget) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(widget);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 800));

  await tester.runAsync(() async {
    final boundary = tester.renderObject(find.byKey(const Key('screen_shot'))) as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    expect(bytes, isNotNull);

    final file = File(p.join(_screenshotDir().path, '$name.png'));
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = true;
    try {
      await Supabase.initialize(
        url: 'https://bvwiqmyvvbowkteutxfb.supabase.co',
        anonKey: 'sb_publishable_I5mJspChdvby2BP7GuVJnQ_lddFryLx',
      );
    } catch (_) {
      // Already initialized in another test file.
    }
  });

  final cases = <(String, Widget Function())>[
    ('01_login', () => _wrap(const LoginScreen())),
    ('02_register', () => _wrap(const RegisterScreen())),
    ('03_otp_verification', () => _wrap(const OtpVerificationScreen(email: 'test@aneuso.com', purpose: 'registration'))),
    ('04_profile', () => _wrap(const ProfileScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('05_dashboard_admin', () => _wrap(const DashboardScreen(), user: _user(AppConstants.userTypeAdmin, name: 'Admin User'))),
    ('06_dashboard_industry', () => _wrap(const DashboardScreen(), user: _user(AppConstants.userTypeIndustry, name: 'Industry User'))),
    ('07_dashboard_driver', () => _wrap(const DashboardScreen(), user: _user(AppConstants.userTypeDriver, name: 'Driver User'))),
    ('08_dashboard_citizen', () => _wrap(const DashboardScreen(), user: _user(AppConstants.userTypeCitizen, name: 'Citizen User'))),
    ('09_products', () => _wrap(const ProductsScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('10_cart', () => _wrap(const CartScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('11_orders', () => _wrap(const OrdersScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('12_report_garbage', () => _wrap(const ReportGarbageScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('13_cleanup_campaigns', () => _wrap(const CleanupCampaignsScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('14_schedule_pickup', () => _wrap(const SchedulePickup(), user: _user(AppConstants.userTypeIndustry))),
    ('15_create_deal', () => _wrap(const CreateDealScreen(), user: _user(AppConstants.userTypeIndustry))),
    ('16_service_history', () => _wrap(ServiceHistoryScreen(), user: _user(AppConstants.userTypeIndustry))),
    ('17_three_bin_training', () => _wrap(const IndustryThreeBinTrainingScreen(), user: _user(AppConstants.userTypeIndustry))),
    ('18_driver_daily_tasks', () => _wrap(const DriverTasksScreen(), user: _user(AppConstants.userTypeDriver))),
    ('19_confirm_pickups', () => _wrap(const ConfirmPickupsScreen(), user: _user(AppConstants.userTypeDriver))),
    ('20_driver_missions', () => _wrap(const DriverMissionScreen(), user: _user(AppConstants.userTypeDriver))),
    ('21_driver_my_ratings', () => _wrap(const DriverMyRatingsScreen(), user: _user(AppConstants.userTypeDriver))),
    ('22_companies', () => _wrap(const CompanyListScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('23_branches', () => _wrap(const BranchListScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('24_branch_stats', () => _wrap(const BranchStatsScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('25_admin_products', () => _wrap(const AdminProductsScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('26_admin_product_form', () => _wrap(const ProductFormScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('27_admin_deals', () => _wrap(AdminDealsScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('28_admin_pickups', () => _wrap(const AdminPickupsScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('29_admin_broadcast', () => _wrap(const AdminBroadcastScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('30_admin_driver_ratings', () => _wrap(const AdminDriverRatingsScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('31_admin_cleanup_dashboard', () => _wrap(const AdminCleanupDashboard(), user: _user(AppConstants.userTypeAdmin))),
    ('32_public_garbage_reports', () => _wrap(const PublicGarbageReportsScreen(), user: _user(AppConstants.userTypeAdmin))),
    ('33_messages_hub', () => _wrap(const MessagesHubScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('34_jobs_list', () => _wrap(const JobsListScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('35_tutorials_topics', () => _wrap(const TopicsListScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('36_tutorials_home', () => _wrap(const TutorialsHomeScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('37_notifications', () => _wrap(const NotificationInboxScreen(), user: _user(AppConstants.userTypeCitizen))),
    ('38_live_tracking', () => _wrap(const LiveTrackingScreen(taskId: 1, taskType: 'industry_pickup'), user: _user(AppConstants.userTypeCitizen))),
  ];

  for (final entry in cases) {
    testWidgets('capture ${entry.$1}', (tester) async {
      try {
        await _capture(tester, entry.$1, entry.$2());
      } catch (_) {
        // Some screens need live API/maps; skip failed captures.
      }
    });
  }
}
