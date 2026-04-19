import 'package:aneuso_app/presentation/screens/citizen/cart_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/orders_screen.dart';
import 'package:aneuso_app/presentation/screens/citizen/report_garbage_screen.dart';
import 'package:aneuso_app/presentation/screens/driver/ConfirmPickupsScreen.dart';
import 'package:aneuso_app/presentation/screens/driver/DailyTasksScreen.dart';
import 'package:aneuso_app/presentation/screens/industry/ServiceHistoryScreen.dart';
import 'package:aneuso_app/presentation/screens/industry/schedule_pickup.dart';
import 'package:aneuso_app/presentation/screens/public_garbage_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/utils/storage_util.dart';
import 'services/auth_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/otp_verification_screen.dart';
import 'presentation/providers/company_provider.dart';
import 'presentation/providers/admin_product_provider.dart';
import 'presentation/screens/company_list_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/providers/branch_provider.dart';
import 'presentation/providers/tutorial_provider.dart';
import 'presentation/screens/branch_list_screen.dart';
import 'presentation/screens/branch_stats_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/topics_list_screen.dart';
import 'presentation/screens/topic_detail_screen.dart';
import 'presentation/screens/video_detail_screen.dart';
import 'presentation/screens/video_player_screen.dart';
import 'presentation/screens/tutorials_home_screen.dart';
import 'presentation/screens/products_screen.dart';
import 'presentation/screens/admin/admin_products_screen.dart';
import 'presentation/screens/admin/product_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageUtil.init();

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
      ],
      child: MaterialApp(
        title: 'ANEUSO - Waste Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
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
          '/admin/product/form': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>?;
            return ProductFormScreen(productId: args?['id'] as int?);
          },
          '/companies': (context) => const CompanyListScreen(),
          '/branches': (context) => const BranchListScreen(),
          '/branches/stats': (context) => const BranchStatsScreen(),

          // Industry routes
          '/industry/schedule_pickup': (context) => const SchedulePickup(),
          '/industry/service_history': (context) => ServiceHistoryScreen(),

          // Driver routes
          '/driver/driverdailytasks': (context) => const DriverTasksScreen(),
          '/driver/confirm_pickups': (context) => const ConfirmPickupsScreen(),

          // Citizen routes
          '/products': (context) => const ProductsScreen(),
          '/citizen/mycart': (context) => const CartScreen(),
          '/citizen/myorders': (context) => const OrdersScreen(),
          '/citizen/report-garbage': (context) => const ReportGarbageScreen(),
        },
      ),
    );
  }
}
