import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/utils/storage_util.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final token = StorageUtil.getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    
    // Handle token expiration
    if (response.statusCode == 401) {
      await StorageUtil.clearAuthData();
      throw Exception('Authentication failed. Please login again.');
    }
    
    return response;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final token = StorageUtil.getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    
    // Handle token expiration
    if (response.statusCode == 401) {
      await StorageUtil.clearAuthData();
      throw Exception('Authentication failed. Please login again.');
    }
    
    return response;
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final token = StorageUtil.getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.put(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    
    // Handle token expiration
    if (response.statusCode == 401) {
      await StorageUtil.clearAuthData();
      throw Exception('Authentication failed. Please login again.');
    }
    
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final token = StorageUtil.getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.delete(url, headers: headers);
    
    // Handle token expiration
    if (response.statusCode == 401) {
      await StorageUtil.clearAuthData();
      throw Exception('Authentication failed. Please login again.');
    }
    
    return response;
  }
}