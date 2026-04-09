import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/product.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final resp = await http.get(uri, headers: await _headers())
        .timeout(const Duration(seconds: 15));
    return _handle(resp);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConstants.baseUrl}$path');
    final resp = await http.post(uri,
        headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    return _handle(resp);
  }

  dynamic _handle(http.Response resp) {
    if (resp.statusCode == 401) {
      throw ApiException('Session expired. Please log in again.',
          statusCode: 401);
    }
    final body = jsonDecode(resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) return body;
    final msg = body['error'] ?? body['message'] ?? 'Request failed';
    throw ApiException(msg.toString(), statusCode: resp.statusCode);
  }

  // --- Auth ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  // --- Products ---
  Future<List<Product>> searchProducts({
    String? query,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null && query.isNotEmpty) 'search': query,
    };
    final qs = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final data = await _get('/api/products?$qs');

    List<dynamic> list;
    if (data is Map && data.containsKey('products')) {
      list = data['products'] as List<dynamic>;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    return list.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
  }

  // --- Customer lookup ---
  Future<Map<String, dynamic>?> findCustomerByPhone(String phone) async {
    try {
      final data = await _get('/api/customers/phone/$phone');
      return data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customer) async {
    return (await _post('/api/customers', customer)) as Map<String, dynamic>;
  }

  // --- Sales ---
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> sale) async {
    return (await _post('/api/sales', sale)) as Map<String, dynamic>;
  }
}
