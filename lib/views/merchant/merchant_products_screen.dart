import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../../view_models/auth_viewmodel.dart';
import '../../view_models/merchant_viewmodel.dart';
import '../../view_models/product_viewmodel.dart';
import '../../models/product_model.dart';

class MerchantProductsScreen extends StatefulWidget {
  const MerchantProductsScreen({super.key});

  @override
  State<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends State<MerchantProductsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    final authViewModel = context.read<AuthViewModel>();

    final merchantViewModel = context.read<MerchantViewModel>();

    final productViewModel = context.read<ProductViewModel>();

    final userId = authViewModel.profile?.id;

    if (userId == null) {
      return;
    }

    await merchantViewModel.loadMerchant(userId);

    final merchant = merchantViewModel.merchant;

    if (merchant == null) {
      return;
    }

    if (merchant.approvalStatus != 'approved') {
      return;
    }

    await productViewModel.loadMerchantProducts(merchant.id);

    await productViewModel.loadCategories();
  }

  Future<void> _showProductForm({ProductModel? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');

    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    final priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(2) : '',
    );

    String? selectedCategoryId = product?.categoryId;

    final productViewModel = context.read<ProductViewModel>();

    final merchantViewModel = context.read<MerchantViewModel>();

    final merchant = merchantViewModel.merchant;

    if (merchant == null) {
      return;
    }

    final formKey = GlobalKey<FormState>();

    Uint8List? selectedImageBytes;
    String? selectedImageName;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(product == null ? 'Add Product' : 'Edit Product'),

              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a product name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            prefixText: 'R ',
                          ),
                          validator: (value) {
                            final price = double.tryParse(value ?? '');

                            if (price == null || price < 0) {
                              return 'Enter a valid price';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: productViewModel.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final file = await FilePicker.pickFile(
                              type: FileType.image,
                            );

                            if (file == null) {
                              return;
                            }

                            final bytes = await file.readAsBytes();

                            setState(() {
                              selectedImageBytes = bytes;
                              selectedImageName = file.name;
                            });
                          },
                          icon: const Icon(Icons.image),
                          label: Text(
                            selectedImageName == null
                                ? 'Choose Product Image'
                                : 'Change Image',
                          ),
                        ),
                        if (selectedImageBytes != null) ...[
                          const SizedBox(height: 12),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              selectedImageBytes!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: productViewModel.isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          final price = double.parse(
                            priceController.text.trim(),
                          );

                          bool success;

                          String? imageUrl;

                          if (selectedImageBytes != null) {
                            imageUrl = await productViewModel
                                .uploadProductImage(
                                  userId: context
                                      .read<AuthViewModel>()
                                      .profile!
                                      .id,
                                  fileName:
                                      selectedImageName ?? 'product_image.jpg',
                                  fileBytes: selectedImageBytes!,
                                );

                            if (imageUrl == null) {
                              return;
                            }
                          }

                          if (product == null) {
                            success = await productViewModel.createProduct(
                              merchantId: merchant.id,
                              categoryId: selectedCategoryId,
                              name: nameController.text.trim(),
                              description:
                                  descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              price: price,
                              imageUrl: imageUrl,
                            );
                          } else {
                            success = await productViewModel.updateProduct(
                              productId: product.id,
                              categoryId: selectedCategoryId,
                              name: nameController.text.trim(),
                              description:
                                  descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              price: price,
                              imageUrl: imageUrl,
                            );
                          }

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  product == null
                                      ? 'Product added successfully.'
                                      : 'Product updated successfully.',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  productViewModel.errorMessage ??
                                      'Something went wrong.',
                                ),
                              ),
                            );
                          }
                        },
                  child: Text(product == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }

  Future<void> _toggleAvailability(ProductModel product) async {
    final productViewModel = context.read<ProductViewModel>();

    final success = await productViewModel.updateProduct(
      productId: product.id,
      isAvailable: !product.isAvailable,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? product.isAvailable
                    ? 'Product marked unavailable.'
                    : 'Product marked available.'
              : productViewModel.errorMessage ?? 'Unable to update product.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final productViewModel = context.read<ProductViewModel>();

    final success = await productViewModel.deleteProduct(product.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Product deleted successfully.'
              : productViewModel.errorMessage ?? 'Unable to delete product.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final merchantViewModel = context.watch<MerchantViewModel>();

    final productViewModel = context.watch<ProductViewModel>();

    if (merchantViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final merchant = merchantViewModel.merchant;

    if (merchant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Products')),
        body: const Center(child: Text('Merchant profile not found.')),
      );
    }

    if (merchant.approvalStatus != 'approved') {
      return Scaffold(
        appBar: AppBar(title: const Text('My Products')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pending_actions, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Merchant approval required',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your merchant account must be approved by an administrator before you can manage products.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: productViewModel.isLoading ? null : () => _showProductForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: productViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productViewModel.products.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: productViewModel.products.length,
                itemBuilder: (context, index) {
                  final product = productViewModel.products[index];

                  return _buildProductCard(product);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 72),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first product to start building your menu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showProductForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ],
        ),
      ),
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
              width: 70,
              height: 70,
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
                  : const Icon(Icons.fastfood, size: 32),
            ),

            const SizedBox(width: 12),

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

                  const SizedBox(height: 6),

                  Text(
                    'R ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        product.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(product.isAvailable ? 'Available' : 'Unavailable'),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showProductForm(product: product);
                }

                if (value == 'delete') {
                  _confirmDelete(product);
                }

                if (value == 'toggle') {
                  _toggleAvailability(product);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(
                      product.isAvailable
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    title: Text(
                      product.isAvailable
                          ? 'Mark Unavailable'
                          : 'Mark Available',
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
