import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> saleData;

  const ReceiptScreen({super.key, required this.saleData});

  @override
  Widget build(BuildContext context) {
    final invoiceNo = saleData['invoice_number'] ?? saleData['id'] ?? '-';
    final items = (saleData['items'] as List<dynamic>? ?? []);
    final total = saleData['total'] ?? 0.0;
    final subtotal = saleData['subtotal'] ?? total;
    final discount = saleData['discount'] ?? 0.0;
    final paymentMode = (saleData['payment_mode'] ?? 'cash').toString().toUpperCase();
    final customerName = saleData['customer_name'] ?? '';
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'New Sale',
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Success icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                    ),
                    const SizedBox(height: 12),
                    const Text('Sale Completed!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Invoice #$invoiceNo',
                        style: TextStyle(color: Colors.grey.shade600)),
                    Text(now,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 24),
                    const Divider(),

                    // Customer
                    if (customerName.isNotEmpty) ...[
                      _InfoRow(
                          label: 'Customer', value: customerName),
                      const SizedBox(height: 8),
                    ],

                    // Items
                    ...items.map<Widget>((item) {
                      final name = item['name'] ?? item['product_name'] ?? '';
                      final qty = item['quantity'] ?? 1;
                      final price = item['unit_price'] ?? 0.0;
                      final lineTotal = item['total'] ?? (qty * price);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text('$name × $qty',
                                  style: const TextStyle(fontSize: 14)),
                            ),
                            Text(
                              '₹${(lineTotal as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 24),

                    // Totals
                    _InfoRow(
                        label: 'Subtotal',
                        value: '₹${(subtotal as num).toStringAsFixed(2)}'),
                    if ((discount as num) > 0)
                      _InfoRow(
                          label: 'Discount',
                          value: '- ₹${discount.toStringAsFixed(2)}',
                          valueColor: Colors.green),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${(total as num).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Payment', value: paymentMode),

                    const SizedBox(height: 24),

                    // New sale button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('New Sale',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () =>
                            Navigator.popUntil(context, (r) => r.isFirst),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor)),
        ],
      ),
    );
  }
}
