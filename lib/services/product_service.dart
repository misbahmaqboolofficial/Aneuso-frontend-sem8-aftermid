import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';

import '../services/api_service.dart';
import '../data/models/product_model.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 9999,
    int? statusId,
  }) async {
    var query = '/products?page=$page&limit=$limit';
    if (statusId != null) {
      query += '&status_id=$statusId';
    }
    final response = await _api.get(query);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final data = body['data'] as List;
        return data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw Exception(body['message'] ?? 'Failed to load products');
      }
    } else {
      final errBody = response.body.isNotEmpty ? response.body : 'No response body';
      throw Exception('Failed to load products: ${response.statusCode} - $errBody');
    }
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _api.get('/products/$id');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return ProductModel.fromJson(body['data']);
      }
    }
    throw Exception('Failed to load product');
  }

  Future<ProductModel> createProduct(Map<String, dynamic> body) async {
    final response = await _api.post('/products', body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resp = jsonDecode(response.body);
      if (resp['success'] == true) {
        return ProductModel.fromJson(resp['data']);
      }
      throw Exception(resp['message'] ?? 'Failed to create product');
    }
    throw Exception('Failed to create product: ${response.statusCode}');
  }

  Future<ProductModel> updateProduct(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/products/$id', body: body);
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      debugPrint('Update Product Response: $resp');
      if (resp['success'] == true) {
        return getProductById(id);
      }
      throw Exception(resp['message'] ?? 'Failed to update product');
    }
    throw Exception('Failed to update product: ${response.statusCode}');
  }

  Future<bool> deleteProduct(int id) async {
    final response = await _api.delete('/products/$id');
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      return resp['success'] == true;
    }
    throw Exception('Failed to delete product: ${response.statusCode}');
  }

  // Upload images using multipart/form-data
  Future<List<String>> uploadImages(int productId, List<File> files) async {
    final token = StorageUtil.getToken();
    final uri = Uri.parse('${AppConstants.baseUrl}/products/$productId/images');

    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    for (var file in files) {
      final multipart = await http.MultipartFile.fromPath('images', file.path);
      request.files.add(multipart);
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final body = jsonDecode(resp.body);
      if (body['success'] == true) {
        final data = body['data'] as List<dynamic>?;
        return data?.map((e) => e.toString()).toList() ?? [];
      }
      throw Exception(body['message'] ?? 'Failed to upload images');
    }
    throw Exception('Failed to upload images: ${resp.statusCode}');
  }

  Future<bool> removeImage(int productId, String url) async {
    final response = await _api.post(
      '/products/$productId/images/remove',
      body: {'url': url},
    );
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      return resp['success'] == true;
    }
    throw Exception('Failed to remove image: ${response.statusCode}');
  }

  Future<bool> updateStock(int productId, int stockQuantity) async {
    final response = await _api.post(
      '/products/$productId/stock',
      body: {'stock_quantity': stockQuantity},
    );
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      return resp['success'] == true;
    }
    throw Exception('Failed to update stock: ${response.statusCode}');
  }
}
