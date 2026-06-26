import 'package:aneuso_app/presentation/screens/citizen/cart_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/orders_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/report_garbage_screen.dart';
import 'package:aneuso_app/presentation/screens/driver/ConfirmPickupsScreen.dart';
import 'package:aneuso_app/presentation/screens/driver/DailyTasksScreen.dart';
import 'package:aneuso_app/presentation/screens/industry/ServiceHistoryScreen.dart';
import 'package:aneuso_app/presentation/screens/industry/schedule_pickup.dart';
import 'package:aneuso_app/presentation/screens/admin/public_garbage_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/global_notification_listener.dart';
import 'core/utils/local_notification_service.dart';
import 'core/utils/storage_util.dart';
import 'data/services/driver_tracking_service.dart';
import 'services/auth_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/otp_verification_screen.dart';
import 'presentation/providers/company_provider.dart';
import 'presentation/providers/admin_product_provider.dart';
import 'presentation/screens/admin/company_list_screen.dart';
import 'presentation/screens/common/dashboard_screen.dart';
import 'presentation/providers/branch_provider.dart';
import 'presentation/providers/tutorial_provider.dart';
import 'presentation/providers/driver_ratings_provider.dart';
import 'presentation/screens/driver/driver_my_ratings_screen.dart';
import 'presentation/screens/admin/admin_driver_ratings_screen.dart';
import 'presentation/screens/admin/branch_list_screen.dart';
import 'presentation/screens/admin/branch_stats_screen.dart';
import 'presentation/screens/common/profile_screen.dart';
import 'presentation/screens/common/tutorials/topics_list_screen.dart';
import 'presentation/screens/common/tutorials/topic_detail_screen.dart';
import 'presentation/screens/common/tutorials/video_detail_screen.dart';
import 'presentation/screens/common/tutorials/video_player_screen.dart';
import 'presentation/screens/common/tutorials/tutorials_home_screen.dart';
import 'presentation/screens/citizen/products_screen.dart';
import 'presentation/screens/admin/admin_products_screen.dart';
import 'presentation/screens/admin/product_form_screen.dart';
import 'presentation/screens/admin/admin_deals_screen.dart';
import 'presentation/screens/industry/create_deal_screen.dart';
import 'presentation/screens/industry/view_deals_screen.dart';
import 'presentation/screens/admin/admin_pickups_screen.dart';
import 'presentation/screens/citizen/CleanupCampaignsScreen.dart';
import 'presentation/screens/citizen/CampaignDetailScreen.dart';
import 'presentation/screens/admin/AdminCleanupDashboard.dart';
import 'presentation/screens/admin/admin_broadcast_screen.dart';
import 'presentation/screens/industry/industry_three_bin_training_screen.dart';
import 'presentation/screens/common/live_tracking_screen.dart';
import 'presentation/screens/chat/messages_hub_screen.dart';
import 'presentation/providers/job_provider.dart';
import 'presentation/screens/common/jobs/jobs_list_screen.dart';
import 'presentation/screens/common/jobs/job_detail_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/app_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageUtil.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://bvwiqmyvvbowkteutxfb.supabase.co',
    anonKey: 'sb_publishable_I5mJspChdvby2BP7GuVJnQ_lddFryLx',
  );

  // Initialize notifications
  await LocalNotificationService.initialize();

  // Resume driver background GPS if a pickup was being tracked
  await DriverTrackingService.instance.restoreSessionIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(AuthService())..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => BranchProvider()),
        ChangeNotifierProvider(create: (_) => TutorialProvider()),
        ChangeNotifierProvider(create: (_) => AdminProductProvider()),
        ChangeNotifierProvider(create: (_) => DriverRatingsProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
      ],
      child: MaterialApp(
        title: 'ANEUSO - Waste Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          final auth = context.watch<AuthProvider>();
          Widget appChild =
              AppResponsiveScope(child: child ?? const SizedBox.shrink());

          if (auth.isLoggedIn && auth.currentUser != null) {
            appChild = GlobalNotificationListener(
              userId: auth.currentUser!.id,
              child: appChild,
            );
          }

          return appChild;
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            return authProvider.isLoggedIn
                ? const DashboardScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/tutorials': (context) => const TopicsListScreen(),
          '/tutorials/home': (context) => const TutorialsHomeScreen(),
          '/tutorials/topic': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>?;
            return TopicDetailScreen(topicId: args?['id'] ?? 0);
          },
          '/tutorials/video': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>?;
            return VideoDetailScreen(videoId: args?['id'] ?? 0);
          },
          '/tutorials/video/player': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>?;
            final url = args?['url'] as String? ?? '';
            final title = args?['title'] as String?;
            return VideoPlayerScreen(url: url, title: title);
          },
          '/otp-verification': (context) {
            final arguments =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>?;
            return OtpVerificationScreen(
              email: arguments?['email'] ?? '',
              purpose: arguments?['purpose'] ?? 'registration',
              user: arguments?['user'],
            );
          },
          '/dashboard': (context) => const DashboardScreen(),
          '/admin-dashboard': (context) => const DashboardScreen(),
          '/industry-dashboard': (context) => const DashboardScreen(),
          '/driver-dashboard': (context) => const DashboardScreen(),
          '/citizen-dashboard': (context) => const DashboardScreen(),
          '/garbage-reports': (context) => const PublicGarbageReportsScreen(),

          // Admin routes
          '/admin/products': (context) => const AdminProductsScreen(),
          '/admin/deals': (context) => AdminDealsScreen(),
          '/admin/product/form': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>?;
            return ProductFormScreen(productId: args?['id'] as int?);
          },
          '/companies': (context) => const CompanyListScreen(),
          '/branches': (context) => const BranchListScreen(),
          '/branches/stats': (context) => const BranchStatsScreen(),
          '/admin/all_pickups': (context) => const AdminPickupsScreen(),
          '/driver/my_ratings': (context) => const DriverMyRatingsScreen(),
          '/admin/driver_ratings': (context) => const AdminDriverRatingsScreen(),
          '/admin/broadcast': (context) => const AdminBroadcastScreen(),

          // Industry routes
          '/industry/schedule_pickup': (context) => const SchedulePickup(),
          '/industry/three-bin-training': (context) => const IndustryThreeBinTrainingScreen(),
          '/industry/service_history': (context) => ServiceHistoryScreen(),
          '/industry/create_deal': (context) => CreateDealScreen(),
          '/industry/view_deals': (context) => const ViewDealsScreen(),

          // Driver routes
          '/driver/driverdailytasks': (context) => const DriverTasksScreen(),
          '/driver/confirm_pickups': (context) => const ConfirmPickupsScreen(),

          // Citizen routes
          '/products': (context) => const ProductsScreen(),
          '/citizen/mycart': (context) => const CartScreen(),
          '/citizen/myorders': (context) => const OrdersScreen(),
          '/citizen/report-garbage': (context) => const ReportGarbageScreen(),
          '/citizen/cleanup-campaigns': (context) => const CleanupCampaignsScreen(),
          '/citizen/campaign-detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return CampaignDetailScreen(reportId: args?['id'] ?? 0);
          },
          '/admin/cleanup-dashboard': (context) => const AdminCleanupDashboard(),

          // Live Tracking
          '/messages': (context) => const MessagesHubScreen(),
          '/jobs': (context) => const JobsListScreen(),
          '/jobs/detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return JobDetailScreen(jobId: args?['id'] ?? 0);
          },

          '/live-tracking': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return LiveTrackingScreen(
              taskId: (args?['task_id'] ?? args?['pickup_id']) as int? ?? 0,
              taskType: args?['task_type'] as String? ?? 'industry_pickup',
            );
          },
        },
      ),
    );
  }
}
