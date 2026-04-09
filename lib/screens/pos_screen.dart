import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/cart_panel.dart';
import '../widgets/payment_sheet.dart';
import '../widgets/product_card.dart';
import 'receipt_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  // Default storeId = 1; ideally fetched from user profile
  static const int _storeId = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadInitial();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProductsProvider>().search(query);
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CartProvider>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scroll) => CartPanel(onCheckout: _checkout),
        ),
      ),
    );
  }

  void _checkout() {
    Navigator.pop(context); // close cart sheet first
    PaymentSheet.show(context, _storeId, _onSaleComplete);
  }

  void _onSaleComplete() {
    final cart = context.read<CartProvider>();
    final saleData = cart.lastSale;
    cart.clear();
    if (saleData != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ReceiptScreen(saleData: saleData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlino POS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!isWide)
            Consumer<CartProvider>(
              builder: (context, cart, _) => Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: cart.isEmpty ? null : _openCart,
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: isWide ? _wideLayout() : _narrowLayout(),
      floatingActionButton: !isWide
          ? Consumer<CartProvider>(
              builder: (context, cart, _) => cart.isEmpty
                  ? const SizedBox.shrink()
                  : FloatingActionButton.extended(
                      onPressed: () {
                        PaymentSheet.show(context, _storeId, _onSaleComplete);
                      },
                      icon: const Icon(Icons.payment),
                      label:
                          Text('Pay ₹${cart.total.toStringAsFixed(0)}'),
                    ),
            )
          : null,
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        Expanded(flex: 3, child: _productSection()),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 320,
          child: CartPanel(
            onCheckout: () =>
                PaymentSheet.show(context, _storeId, _onSaleComplete),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return _productSection();
  }

  Widget _productSection() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name, SKU, barcode...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearch('');
                      })
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Products grid
        Expanded(
          child: Consumer<ProductsProvider>(
            builder: (context, products, _) {
              if (products.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (products.error != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(products.error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: () =>
                              context.read<ProductsProvider>().loadInitial(),
                          child: const Text('Retry')),
                    ],
                  ),
                );
              }
              if (products.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 56, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        products.query.isEmpty
                            ? 'No products found'
                            : 'No results for "${products.query}"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final isWide = MediaQuery.of(context).size.width >= 720;
              final cols = isWide ? 4 : 2;
              final cart = context.read<CartProvider>();

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.products.length,
                itemBuilder: (context, i) {
                  final product = products.products[i];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      cart.addProduct(product);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text('Added: ${product.name}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            width: 280,
                          ),
                        );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CartProvider>().clear();
      context.read<ProductsProvider>().clear();
      context.read<AuthProvider>().logout();
    }
  }
}
