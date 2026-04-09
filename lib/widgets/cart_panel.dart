import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPanel extends StatelessWidget {
  final VoidCallback onCheckout;

  const CartPanel({super.key, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(Icons.shopping_cart,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    'Cart (${cart.itemCount})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  if (!cart.isEmpty)
                    TextButton(
                      onPressed: () => _confirmClear(context, cart),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),

            // Items list
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined,
                              size: 56,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 8),
                          Text('Cart is empty',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.outline)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16),
                      itemBuilder: (context, i) {
                        final item = cart.items[i];
                        return ListTile(
                          dense: true,
                          title: Text(
                            item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Text(
                              '₹${item.unitPrice.toStringAsFixed(0)} × ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${item.lineTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              _QtyControl(
                                quantity: item.quantity,
                                onMinus: () => cart.updateQuantity(
                                    item.product.id, item.quantity - 1),
                                onPlus: () => cart.updateQuantity(
                                    item.product.id, item.quantity + 1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Totals
            if (!cart.isEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _TotalRow(
                        label: 'Subtotal',
                        value: '₹${cart.subtotal.toStringAsFixed(2)}'),
                    if (cart.discountAmount > 0)
                      _TotalRow(
                          label: 'Discount',
                          value: '- ₹${cart.discountAmount.toStringAsFixed(2)}',
                          highlight: true),
                    const Divider(height: 16),
                    _TotalRow(
                      label: 'TOTAL',
                      value: '₹${cart.total.toStringAsFixed(2)}',
                      bold: true,
                      large: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Checkout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: onCheckout,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context, CartProvider cart) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Remove all items from the cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) cart.clear();
  }
}

class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyControl(
      {required this.quantity,
      required this.onMinus,
      required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: Icon(
                quantity <= 1 ? Icons.delete_outline : Icons.remove,
                size: 18,
                color: quantity <= 1 ? Colors.red : null),
            onPressed: onMinus,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        Text('$quantity',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: onPlus,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool large;
  final bool highlight;

  const _TotalRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.large = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: large ? 18 : 14,
      color: highlight ? Colors.green : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
