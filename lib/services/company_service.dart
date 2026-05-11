import 'dart:convert';

// import 'package:http/http.dart' as http;

// import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../domain/entities/company_entity.dart';

class CompanyService {
  final ApiService _api = ApiService();

  Future<List<CompanyEntity>> getCompanies({
    int page = 1,
    int limit = 9999,
  }) async {
    final response = await _api.get('/companies?page=$page&limit=$limit');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final data = body['data'] as List;
        return data.map((e) => CompanyEntity.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load companies');
  }

  Future<CompanyEntity> createCompany(Map<String, dynamic> body) async {
    final response = await _api.post('/companies', body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resp = jsonDecode(response.body);
      if (resp['success'] == true) {
        return CompanyEntity.fromJson(resp['data']);
      }
      throw Exception(resp['message'] ?? 'Failed to create company');
    }
    throw Exception('Failed to create company: ${response.statusCode}');
  }

  Future<bool> deleteCompany(int id) async {
    final response = await _api.delete('/companies/$id');
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      return resp['success'] == true;
    }
    throw Exception('Failed to delete company: ${response.statusCode}');
  }

  // Update company
  Future<CompanyEntity> updateCompany(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/companies/$id', body: body);
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      if (resp['success'] == true) {
        return CompanyEntity.fromJson(resp['data']);
      }
      throw Exception(resp['message'] ?? 'Failed to update company');
    }
    throw Exception('Failed to update company: ${response.statusCode}');
  }

  // Get companies with pagination and optional search
  Future<Map<String, dynamic>> getCompaniesPage({
    int page = 1,
    int limit = 9999,
    String? search,
  }) async {
    final query = StringBuffer('/companies?page=$page&limit=$limit');
    if (search != null && search.isNotEmpty) {
      query.write('&search=${Uri.encodeComponent(search)}');
    }

    final response = await _api.get(query.toString());
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final data = (body['data'] as List)
            .map((e) => CompanyEntity.fromJson(e))
            .toList();
        final pagination = body['pagination'] as Map<String, dynamic>?;
        return {'companies': data, 'pagination': pagination};
      }
    }
    throw Exception('Failed to load companies');
  }

  Future<List<dynamic>> getBusinessTypes() async {
    final response = await _api.get('/companies/types/business-types');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return body['data'] as List<dynamic>;
      }
    }
    throw Exception('Failed to load business types');
  }

  Future<List<dynamic>> getCompanyTypes() async {
    final response = await _api.get('/companies/types/company-types');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return body['data'] as List<dynamic>;
      }
    }
    throw Exception('Failed to load company types');
  }

  Future<List<dynamic>> getWasteTypes() async {
    final response = await _api.get('/companies/types/waste-types');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return body['data'] as List<dynamic>;
      }
    }
    throw Exception('Failed to load waste types');
  }
}
