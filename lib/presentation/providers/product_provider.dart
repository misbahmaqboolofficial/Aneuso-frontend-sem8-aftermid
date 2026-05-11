import 'package:flutter/foundation.dart';
import 'package:aneuso_app/services/product_service.dart';
import 'package:aneuso_app/data/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts() async {
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

  Future<ProductModel?> fetchProductById(int id) async {
    try {
      return await _service.getProductById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}
