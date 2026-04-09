import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum CartStatus { idle, processing, done, error }

class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  final List<CartItem> _items = [];
  double _globalDiscount = 0;
  String _paymentMode = 'cash';
  String _customerName = '';
  String _customerPhone = '';
  CartStatus _status = CartStatus.idle;
  String? _error;
  Map<String, dynamic>? _lastSale;

  List<CartItem> get items => List.unmodifiable(_items);
  double get globalDiscount => _globalDiscount;
  String get paymentMode => _paymentMode;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  CartStatus get status => _status;
  String? get error => _error;
  Map<String, dynamic>? get lastSale => _lastSale;

  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.unitPrice * i.quantity);

  double get discountAmount => _globalDiscount;
  double get afterDiscount => subtotal - discountAmount;
  double get total => afterDiscount > 0 ? afterDiscount : 0;

  void addProduct(Product product) {
    final existing = _items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      _items[existing].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      _items[idx].quantity = quantity;
      notifyListeners();
    }
  }

  void setDiscount(double amount) {
    _globalDiscount = amount.clamp(0, subtotal);
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    _paymentMode = mode;
    notifyListeners();
  }

  void setCustomer({required String name, required String phone}) {
    _customerName = name;
    _customerPhone = phone;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _globalDiscount = 0;
    _paymentMode = 'cash';
    _customerName = '';
    _customerPhone = '';
    _status = CartStatus.idle;
    _error = null;
    _lastSale = null;
    notifyListeners();
  }

  Future<bool> completeSale(int storeId) async {
    if (_items.isEmpty) return false;
    _status = CartStatus.processing;
    _error = null;
    notifyListeners();

    try {
      // Resolve customer
      int? customerId;
      if (_customerPhone.trim().isNotEmpty) {
        try {
          final existing = await _api.findCustomerByPhone(_customerPhone.trim());
          if (existing != null && existing['id'] != null) {
            customerId = existing['id'] as int;
          } else if (_customerName.trim().isNotEmpty) {
            final created = await _api.createCustomer({
              'name': _customerName.trim(),
              'phone': _customerPhone.trim(),
            });
            customerId = created['id'] as int;
          }
        } catch (_) {}
      }

      final sub = subtotal;
      final disc = discountAmount;
      final tot = total;

      final salePayload = {
        'items': _items.map((i) {
          final itemSub = i.unitPrice * i.quantity;
          final globalDiscPct = sub > 0 ? disc / sub : 0.0;
          final itemDisc = itemSub * globalDiscPct;
          return {
            'product_id': i.product.id,
            'product_name': i.product.name,
            'barcode': i.product.barcode,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
            'tax_rate': i.product.taxRate,
            'tax_amount': 0,
            'discount': itemDisc,
            'total_amount': itemSub - itemDisc,
          };
        }).toList(),
        'subtotal': sub,
        'discount': disc,
        'cgst': 0,
        'sgst': 0,
        'total': tot,
        'payment_mode': _paymentMode,
        'notes': '',
        'customer_id': customerId,
        'points_earned': 0,
        'points_redeemed': 0,
        'status': 'completed',
        'storeId': storeId,
        'type': 'sale',
        'fulfillment_status': 'fulfilled',
        'reference_sale_id': null,
        'amount_paid': tot,
        'balance_due': 0,
      };

      final result = await _api.createSale(salePayload);
      _lastSale = {
        ...result,
        'items': _items
            .map((i) => {
                  'name': i.product.name,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                  'total': i.unitPrice * i.quantity,
                })
            .toList(),
        'subtotal': sub,
        'discount': disc,
        'total': tot,
        'payment_mode': _paymentMode,
        'customer_name': _customerName,
        'customer_phone': _customerPhone,
      };

      _status = CartStatus.done;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = CartStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Please try again.';
      _status = CartStatus.error;
      notifyListeners();
      return false;
    }
  }
}
