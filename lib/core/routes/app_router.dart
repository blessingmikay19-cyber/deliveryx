import 'package:go_router/go_router.dart';

import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/customer/customer_dashboard.dart';
import '../../views/merchant/merchant_dashboard.dart';
import '../../views/rider/rider_dashboard.dart';
import '../../views/admin/admin_dashboard.dart';
import '../../views/merchant/merchant_registration_screen.dart';
import '../../views/merchant/merchant_products_screen.dart';
import '../../views/customer/merchant_list_screen.dart';
import '../../views/customer/merchant_menu_screen.dart';
import '../../models/merchant_model.dart';
import '../../views/customer/cart_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerDashboard(),
      ),

      GoRoute(
        path: '/customer/merchants',
        builder: (context, state) => const MerchantListScreen(),
      ),

      GoRoute(
        path: '/customer/merchant/:id',
        builder: (context, state) {
          final merchant = state.extra as MerchantModel;

          return MerchantMenuScreen(merchant: merchant);
        },
      ),

      GoRoute(
        path: '/customer/cart',
        builder: (context, state) => const CartScreen(),
      ),

      GoRoute(
        path: '/merchant',
        builder: (context, state) => const MerchantDashboard(),
      ),

      GoRoute(
        path: '/merchant/register',
        builder: (context, state) => const MerchantRegistrationScreen(),
      ),

      GoRoute(
        path: '/merchant/products',
        builder: (context, state) => const MerchantProductsScreen(),
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
