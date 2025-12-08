import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:aneuso_app/services/product_service.dart';
import 'package:aneuso_app/data/models/product_model.dart';

class AdminProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _service.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> createProduct(Map<String, dynamic> body) async {
    try {
      final p = await _service.createProduct(body);
      _products.insert(0, p);
      notifyListeners();
      return p;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<ProductModel?> updateProduct(int id, Map<String, dynamic> body) async {
    try {
      final p = await _service.updateProduct(id, body);
      final idx = _products.indexWhere((e) => e.id == id);
      if (idx >= 0) _products[idx] = p;
      notifyListeners();
      return p;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final ok = await _service.deleteProduct(id);
      if (ok) _products.removeWhere((e) => e.id == id);
      notifyListeners();
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<String>?> uploadImages(int productId, List<File> files) async {
    try {
      final urls = await _service.uploadImages(productId, files);
      // update local product images if present
      final idx = _products.indexWhere((e) => e.id == productId);
      if (idx >= 0) {
        final updated = ProductModel.fromJson({..._products[idx].toJson(), 'images': urls});
        _products[idx] = updated;
        notifyListeners();
      }
      return urls;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> removeImage(int productId, String url) async {
    try {
      final ok = await _service.removeImage(productId, url);
      if (ok) {
        final idx = _products.indexWhere((e) => e.id == productId);
        if (idx >= 0) {
          final images = _products[idx].images.where((i) => i != url).toList();
          final updated = ProductModel.fromJson({..._products[idx].toJson(), 'images': images});
          _products[idx] = updated;
          notifyListeners();
        }
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(int productId, int stock) async {
    try {
      final ok = await _service.updateStock(productId, stock);
      if (ok) {
        final idx = _products.indexWhere((e) => e.id == productId);
        if (idx >= 0) {
          final updated = ProductModel.fromJson({..._products[idx].toJson(), 'stock_quantity': stock});
          _products[idx] = updated;
          notifyListeners();
        }
      }
      return ok;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
