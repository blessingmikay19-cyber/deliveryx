import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';

class MerchantDashboard extends StatelessWidget {
  const MerchantDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final profile = authViewModel.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              authViewModel.logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Text(
            'Welcome, ${profile?.fullName ?? 'Merchant'}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/merchant/products');
            },
            icon: const Icon(Icons.inventory_2),
            label: const Text('Manage Products'),
          ),
          ],
        ),
      ),
    );
  }
}
