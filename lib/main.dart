import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'view_models/auth_viewmodel.dart';
import 'core/routes/app_router.dart';
import 'view_models/merchant_viewmodel.dart';
import 'view_models/admin_viewmodel.dart';
import 'view_models/product_viewmodel.dart';
import 'view_models/customer_viewmodel.dart';
import 'view_models/cart_viewmodel.dart';

import 'package:material_ui/material_ui.dart' show MaterialUiCompatibilityBridge;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    //anonKey replaced with publishableKey for better security
    publishableKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const DeliverXApp());
}

class DeliverXApp extends StatelessWidget {
  const DeliverXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MerchantViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => CustomerViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        builder: (context, child) {
    return MaterialUiCompatibilityBridge(child: child!);
  },
      ),
    );
  }
}
