import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../view_models/auth_viewmodel.dart';
import '../../view_models/merchant_viewmodel.dart';
import '../../view_models/product_viewmodel.dart';
import '../../models/merchant_model.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() =>
      _MerchantDashboardState();
}

class _MerchantDashboardState
    extends State<MerchantDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    final authViewModel =
        context.read<AuthViewModel>();

    final merchantViewModel =
        context.read<MerchantViewModel>();

    final productViewModel =
        context.read<ProductViewModel>();

    final profileId =
        authViewModel.profile?.id;

    if (profileId == null) {
      return;
    }

    await merchantViewModel.loadMerchant(profileId);

    final merchant =
        merchantViewModel.merchant;

    if (merchant == null ||
        merchant.approvalStatus != 'approved') {
      return;
    }

    await productViewModel.loadMerchantProducts(
      merchant.id,
    );
  }

  Future<void> _toggleStore(bool value) async {
    final merchantViewModel =
        context.read<MerchantViewModel>();

    final merchant =
        merchantViewModel.merchant;

    if (merchant == null) {
      return;
    }

    final success =
        await merchantViewModel.updateMerchant(
      isOpen: value,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? value
                  ? 'Store is now open.'
                  : 'Store is now closed.'
              : merchantViewModel.errorMessage ??
                  'Unable to update store status.',
        ),
      ),
    );
  }

  Future<void> _changePreparationTime() async {
    final merchantViewModel =
        context.read<MerchantViewModel>();

    final merchant =
        merchantViewModel.merchant;

    if (merchant == null) {
      return;
    }

    int selectedTime =
        merchant.preparationTimeMinutes;

    final result =
        await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Preparation Time',
          ),
          content: StatefulBuilder(
            builder: (
              context,
              setState,
            ) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$selectedTime minutes',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),

                  Slider(
                    value: selectedTime
                        .toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label:
                        '$selectedTime minutes',
                    onChanged: (value) {
                      setState(() {
                        selectedTime =
                            value.round();
                      });
                    },
                  ),

                  const Text(
                    'Choose between 5 and 120 minutes.',
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  selectedTime,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    final success =
        await merchantViewModel.updateMerchant(
      preparationTimeMinutes: result,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Preparation time updated to $result minutes.'
              : merchantViewModel.errorMessage ??
                  'Unable to update preparation time.',
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await context
        .read<AuthViewModel>()
        .logout();

    if (!mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final merchantViewModel =
        context.watch<MerchantViewModel>();

    final productViewModel =
        context.watch<ProductViewModel>();

    if (merchantViewModel.isLoading &&
        merchantViewModel.merchant == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final merchant =
        merchantViewModel.merchant;

    // Merchant has not registered yet.
    if (merchant == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Merchant Dashboard',
          ),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: _buildRegistrationRequired(),
      );
    }

    // Merchant is waiting for approval.
    if (merchant.approvalStatus == 'pending') {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Merchant Dashboard',
          ),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: _buildPendingApproval(),
      );
    }

    // Merchant application was rejected.
    if (merchant.approvalStatus == 'rejected') {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Merchant Dashboard',
          ),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: _buildRejected(),
      );
    }

    // Approved merchant dashboard.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          merchant.businessName,
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWelcomeCard(merchant),

            const SizedBox(height: 16),

            _buildStoreStatusCard(merchant),

            const SizedBox(height: 16),

            _buildPreparationTimeCard(merchant),

            const SizedBox(height: 16),

            _buildStatistics(
              productViewModel,
            ),

            const SizedBox(height: 16),

            _buildManageProductsButton(),

            const SizedBox(height: 24),

            _buildBusinessInformation(
              merchant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(
    MerchantModel merchant,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: const Icon(
                Icons.store,
                size: 32,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    merchant.businessName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreStatusCard(
    MerchantModel merchant,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(
          merchant.isOpen
              ? Icons.storefront
              : Icons.storefront_outlined,
        ),
        title: const Text(
          'Store Status',
        ),
        subtitle: Text(
          merchant.isOpen
              ? 'Customers can place orders.'
              : 'Customers cannot place orders.',
        ),
        trailing: Switch(
          value: merchant.isOpen,
          onChanged: merchantViewModelIsLoading()
              ? null
              : _toggleStore,
        ),
      ),
    );
  }

  bool merchantViewModelIsLoading() {
    return context
        .read<MerchantViewModel>()
        .isLoading;
  }

  Widget _buildPreparationTimeCard(
    MerchantModel merchant,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.timer_outlined,
        ),
        title: const Text(
          'Preparation Time',
        ),
        subtitle: const Text(
          'Estimated time to prepare an order.',
        ),
        trailing: TextButton(
          onPressed:
              merchantViewModelIsLoading()
                  ? null
                  : _changePreparationTime,
          child: Text(
            '${merchant.preparationTimeMinutes} min',
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(
    ProductViewModel productViewModel,
  ) {
    final products =
        productViewModel.products;

    final availableProducts =
        products.where(
      (product) => product.isAvailable,
    ).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2_outlined,
            title: 'Products',
            value: products.length.toString(),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline,
            title: 'Available',
            value: availableProducts
                .toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 4),

            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildManageProductsButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          context.push(
            '/merchant/products',
          );
        },
        icon: const Icon(
          Icons.inventory_2,
        ),
        label: const Text(
          'Manage Products',
        ),
      ),
    );
  }

  Widget _buildBusinessInformation(
    MerchantModel merchant,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Business Information',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.business,
              merchant.businessName,
            ),

            if (merchant.businessDescription !=
                    null &&
                merchant.businessDescription!
                    .isNotEmpty)
              _buildInfoRow(
                Icons.description_outlined,
                merchant.businessDescription!,
              ),

            if (merchant.phone != null &&
                merchant.phone!.isNotEmpty)
              _buildInfoRow(
                Icons.phone_outlined,
                merchant.phone!,
              ),

            if (merchant.address != null &&
                merchant.address!.isNotEmpty)
              _buildInfoRow(
                Icons.location_on_outlined,
                merchant.address!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_outlined,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              'Become a Merchant',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'You have not registered a merchant business yet.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/merchant/register',
                );
              },
              icon: const Icon(Icons.store),
              label: const Text(
                'Register Business',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApproval() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pending_actions,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              'Awaiting Approval',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Your merchant application has been submitted and is waiting for administrator approval.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Check Approval Status',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejected() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_outlined,
              size: 72,
            ),

            const SizedBox(height: 20),

            Text(
              'Application Rejected',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Your merchant application was not approved. Please contact the administrator for more information.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}