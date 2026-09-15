import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../view_models/auth_viewmodel.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  Future<void> _logout(
    BuildContext context,
  ) async {
    await context
        .read<AuthViewModel>()
        .logout();

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeliverX'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to DeliverX',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Order from local merchants and get your items delivered.',
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    '/customer/merchants',
                  );
                },
                icon: const Icon(
                  Icons.store,
                ),
                label: const Text(
                  'Browse Merchants',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}