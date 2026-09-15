import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/merchant_model.dart';
import '../../models/product_model.dart';
import '../../view_models/customer_viewmodel.dart';
import '../../view_models/cart_viewmodel.dart';

class MerchantMenuScreen extends StatefulWidget {
  final MerchantModel merchant;

  const MerchantMenuScreen({super.key, required this.merchant});

  @override
  State<MerchantMenuScreen> createState() => _MerchantMenuScreenState();
}

class _MerchantMenuScreenState extends State<MerchantMenuScreen> {
  void _showDifferentMerchantDialog() {
    final cart = context.read<CartViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Different Merchant'),
          content: Text(
            'Your cart already contains items from '
            '${cart.merchant?.businessName}. '
            'You can only order from one merchant at a time.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                cart.clearCart();

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Cart cleared. You can now add items from this merchant.',
                    ),
                  ),
                );
              },
              child: const Text('Clear Cart'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewModel>().loadMerchantMenu(widget.merchant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CustomerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchant.businessName),
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/customer/cart');
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),

                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: viewModel.isLoadingMenu
          ? const Center(child: CircularProgressIndicator())
          : _buildMenu(viewModel),
    );
  }

  Widget _buildMenu(CustomerViewModel viewModel) {
    if (viewModel.errorMessage != null && viewModel.products.isEmpty) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (viewModel.products.isEmpty) {
      return const Center(child: Text('No products are currently available.'));
    }

    final categoryIds = viewModel.products
        .map((product) => product.categoryId)
        .toSet()
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMerchantHeader(),

        const SizedBox(height: 24),

        ...categoryIds.map((categoryId) {
          final products = viewModel.products
              .where((product) => product.categoryId == categoryId)
              .toList();

          final category = viewModel.getCategory(categoryId);

          return _buildCategorySection(category?.name ?? 'Other', products);
        }),
      ],
    );
  }

  Widget _buildMerchantHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.merchant.businessName,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            if (widget.merchant.businessDescription != null &&
                widget.merchant.businessDescription!.isNotEmpty) ...[
              const SizedBox(height: 8),

              Text(widget.merchant.businessDescription!),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.circle, size: 12),

                const SizedBox(width: 6),

                const Text('Open'),

                const SizedBox(width: 20),

                const Icon(Icons.timer_outlined, size: 18),

                const SizedBox(width: 6),

                Text(
                  '${widget.merchant.preparationTimeMinutes} min preparation',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    String categoryName,
    List<ProductModel> products,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            categoryName,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        ...products.map((product) => _buildProductCard(product)),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    )
                  : const Icon(Icons.fastfood, size: 36),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  Text(
                    'R ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: () {
                final cart = context.read<CartViewModel>();

                final added = cart.addItem(
                  product: product,
                  merchant: widget.merchant,
                );

                if (!added) {
                  _showDifferentMerchantDialog();
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart.'),
                    action: SnackBarAction(
                      label: 'VIEW CART',
                      onPressed: () {
                        context.push('/customer/cart');
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}
