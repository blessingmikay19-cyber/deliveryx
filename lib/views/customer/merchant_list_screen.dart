import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../view_models/customer_viewmodel.dart';
import '../../models/merchant_model.dart';

class MerchantListScreen extends StatefulWidget {
  const MerchantListScreen({super.key});

  @override
  State<MerchantListScreen> createState() =>
      _MerchantListScreenState();
}

class _MerchantListScreenState
    extends State<MerchantListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CustomerViewModel>()
          .loadMerchants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        context.watch<CustomerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Merchants'),
      ),

      body: RefreshIndicator(
        onRefresh: () =>
            viewModel.loadMerchants(),

        child: _buildBody(viewModel),
      ),
    );
  }

  Widget _buildBody(
    CustomerViewModel viewModel,
  ) {
    if (viewModel.isLoadingMerchants) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null &&
        viewModel.merchants.isEmpty) {
      return _buildErrorState(viewModel);
    }

    if (viewModel.merchants.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.merchants.length,
      itemBuilder: (context, index) {
        final merchant =
            viewModel.merchants[index];

        return _buildMerchantCard(
          merchant,
        );
      },
    );
  }

  Widget _buildMerchantCard(
    MerchantModel merchant,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () {
          context.push(
            '/customer/merchant/${merchant.id}',
            extra: merchant,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: const Icon(
                      Icons.store,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
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

                        const SizedBox(height: 4),

                        if (merchant
                                    .businessDescription !=
                                null &&
                            merchant
                                .businessDescription!
                                .isNotEmpty)
                          Text(
                            merchant
                                .businessDescription!,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 12,
                  ),

                  const SizedBox(width: 6),

                  const Text('Open'),

                  const Spacer(),

                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    '${merchant.preparationTimeMinutes} min',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.push(
                      '/customer/merchant/${merchant.id}',
                      extra: merchant,
                    );
                  },
                  child: const Text(
                    'View Menu',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height *
                  0.65,
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store_outlined,
                    size: 72,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'No merchants are open',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Please check again later for available merchants.',
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    CustomerViewModel viewModel,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height *
                  0.65,
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                ),

                const SizedBox(height: 16),

                Text(
                  viewModel.errorMessage ??
                      'Something went wrong.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed:
                      viewModel.loadMerchants,
                  child:
                      const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}