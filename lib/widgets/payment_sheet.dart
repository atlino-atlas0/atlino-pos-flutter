import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class PaymentSheet extends StatefulWidget {
  final int storeId;
  final VoidCallback onSuccess;

  const PaymentSheet({
    super.key,
    required this.storeId,
    required this.onSuccess,
  });

  static Future<void> show(
      BuildContext context, int storeId, VoidCallback onSuccess) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<CartProvider>(),
        child: PaymentSheet(storeId: storeId, onSuccess: onSuccess),
      ),
    );
  }

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isGuest = true;

  static const _modes = [
    ('cash', 'Cash', Icons.payments_outlined),
    ('card', 'Card', Icons.credit_card),
    ('upi', 'UPI', Icons.qr_code),
    ('netbanking', 'Net Banking', Icons.account_balance_outlined),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),

              Text('Checkout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Order summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _row('Items', '${cart.itemCount}'),
                    _row('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
                    if (cart.discountAmount > 0)
                      _row('Discount',
                          '- ₹${cart.discountAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    _row('Total', '₹${cart.total.toStringAsFixed(2)}',
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Payment mode
              const Text('Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _modes.map((m) {
                  final (value, label, icon) = m;
                  final selected = cart.paymentMode == value;
                  return ChoiceChip(
                    avatar: Icon(icon, size: 16),
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => cart.setPaymentMode(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Customer (optional)
              Row(
                children: [
                  const Text('Customer',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  Switch(
                    value: !_isGuest,
                    onChanged: (v) => setState(() => _isGuest = !v),
                  ),
                  Text(_isGuest ? 'Guest' : 'Add Info',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              if (!_isGuest) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                            isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                            isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // Error
              if (cart.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(cart.error!,
                      style: const TextStyle(color: Colors.red)),
                ),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: cart.status == CartStatus.processing
                      ? null
                      : () => _confirm(cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: cart.status == CartStatus.processing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          'Confirm ₹${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirm(CartProvider cart) async {
    if (!_isGuest) {
      cart.setCustomer(
          name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim());
    }
    final ok = await cart.completeSale(widget.storeId);
    if (ok && mounted) {
      Navigator.pop(context);
      widget.onSuccess();
    }
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
        : const TextStyle(fontSize: 13);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
