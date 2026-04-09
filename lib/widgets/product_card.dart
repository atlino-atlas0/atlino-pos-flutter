import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.quantity <= 0;
    return GestureDetector(
      onTap: outOfStock ? null : onTap,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Opacity(
          opacity: outOfStock ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Icon(Icons.inventory_2_outlined, size: 40),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      if (product.category != null)
                        Text(
                          product.category!,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${product.sellingPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (outOfStock)
                            const Text('Out',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.red))
                          else
                            Text(
                              'Qty: ${product.quantity}',
                              style: const TextStyle(fontSize: 10),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
