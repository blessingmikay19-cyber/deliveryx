import 'package:go_router/go_router.dart';

import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/customer/customer_dashboard.dart';
import '../../views/merchant/merchant_dashboard.dart';
import '../../views/rider/rider_dashboard.dart';
import '../../views/admin/admin_dashboard.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerDashboard(),
      ),

      GoRoute(
        path: '/merchant',
        builder: (context, state) => const MerchantDashboard(),
      ),

      GoRoute(
        path: '/rider',
        builder: (context, state) => const RiderDashboard(),
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
}