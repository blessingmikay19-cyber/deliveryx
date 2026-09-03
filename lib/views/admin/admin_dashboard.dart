import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/auth_viewmodel.dart';
import '../../view_models/admin_viewmodel.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadPendingMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final adminViewModel = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
      body: RefreshIndicator(
        onRefresh: () {
          return adminViewModel.loadPendingMerchants();
        },
        child: _buildBody(adminViewModel),
      ),
    );
  }

  Widget _buildBody(AdminViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (viewModel.pendingMerchants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 70,
            ),
            SizedBox(height: 16),
            Text(
              'No pending merchant applications.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.pendingMerchants.length,
      itemBuilder: (context, index) {
        final merchant =
            viewModel.pendingMerchants[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (merchant.businessDescription != null &&
                    merchant
                        .businessDescription!
                        .isNotEmpty)
                  Text(
                    merchant.businessDescription!,
                  ),

                const SizedBox(height: 8),

                if (merchant.phone != null)
                  Text(
                    'Phone: ${merchant.phone}',
                  ),

                const SizedBox(height: 4),

                if (merchant.address != null)
                  Text(
                    'Address: ${merchant.address}',
                  ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          viewModel.rejectMerchant(
                            merchant.id,
                          );
                        },
                        child: const Text('Reject'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          viewModel.approveMerchant(
                            merchant.id,
                          );
                        },
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}