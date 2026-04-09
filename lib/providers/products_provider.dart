import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  bool _loading = false;
  String? _error;
  String _query = '';

  List<Product> get products => _products;
  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;

  Future<void> search(String query) async {
    _query = query;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _api.searchProducts(query: query, limit: 60);
    } on ApiException catch (e) {
      _error = e.message;
      _products = [];
    } catch (e) {
      _error = 'Network error';
      _products = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadInitial() => search('');

  void clear() {
    _products = [];
    _query = '';
    _loading = false;
    _error = null;
    notifyListeners();
  }
}
