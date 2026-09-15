import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../view_models/cart_viewmodel.dart';

import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart =
        context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              onPressed: () {
                _showClearCartDialog(context);
              },
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
            ),
        ],
      ),

      body: cart.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.all(16),
                    children: [
                      _buildMerchantCard(
                        context,
                        cart,
                      ),

                      const SizedBox(height: 16),

                      ...cart.items.map(
                        (item) => _buildCartItem(
                          context,
                          item,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildCheckoutBar(
                  context,
                  cart,
                ),
              ],
            ),
    );
  }

  Widget _buildMerchantCard(
    BuildContext context,
    CartViewModel cart,
  ) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.store),
        ),
        title: Text(
          cart.merchant?.businessName ??
              'Merchant',
        ),
        subtitle: const Text(
          'All items in this cart are from this merchant.',
        ),
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItemModel item,
  ) {
    final product = item.product;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildProductImage(product),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'R ${product.price.toStringAsFixed(2)} each',
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context
                              .read<CartViewModel>()
                              .decreaseQuantity(
                                product.id,
                              );
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),

                      Text(
                        '${item.quantity}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),

                      IconButton(
                        onPressed: () {
                          context
                              .read<CartViewModel>()
                              .increaseQuantity(
                                product.id,
                              );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  'R ${item.total.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                IconButton(
                  onPressed: () {
                    context
                        .read<CartViewModel>()
                        .removeItem(
                          product.id,
                        );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(
    ProductModel product,
  ) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: product.imageUrl != null &&
              product.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons
                        .image_not_supported,
                  );
                },
              ),
            )
          : const Icon(
              Icons.fastfood,
              size: 36,
            ),
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    CartViewModel cart,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Text(
                    'Subtotal',
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'R ${cart.subtotal.toStringAsFixed(2)}',
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

            ElevatedButton(
              onPressed: () {
                context.push(
                  '/customer/checkout',
                );
              },
              child: const Text(
                'Checkout',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
            ),

            const SizedBox(height: 20),

            Text(
              'Your cart is empty',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Add products from a merchant to get started.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
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
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Clear Cart?',
          ),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
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
                context
                    .read<CartViewModel>()
                    .clearCart();

                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Clear Cart',
              ),
            ),
          ],
        );
      },
    );
  }
}