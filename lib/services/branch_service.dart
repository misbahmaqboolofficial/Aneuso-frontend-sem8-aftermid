import 'dart:convert';

import '../services/api_service.dart';
import '../domain/entities/branch_entity.dart';

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.errors});

  @override
  String toString() => message;
}

class BranchService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getBranches({
    int page = 1,
    int limit = 9999,
    int? companyId,
    bool? isMain,
    String? search,
  }) async {
    final sb = StringBuffer('/branches?page=$page&limit=$limit');
    if (companyId != null) sb.write('&company_id=$companyId');
    if (isMain != null)
      sb.write('&is_main_branch=${isMain ? 'true' : 'false'}');
    if (search != null && search.isNotEmpty)
      sb.write('&search=${Uri.encodeComponent(search)}');

    final response = await _api.get(sb.toString());
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final data = (body['data'] as List)
          .map((e) => BranchEntity.fromJson(e))
          .toList();
      return {'branches': data, 'pagination': body['pagination']};
    }
    throw ApiException(
      'Failed to load branches',
      errors: body is Map<String, dynamic> ? body : null,
    );
  }

  Future<List<dynamic>> getCompaniesDropdown() async {
    final response = await _api.get('/branches/companies/list');
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true)
      return body['data'] as List<dynamic>;
    throw ApiException(
      'Failed to load companies list',
      errors: body is Map<String, dynamic> ? body : null,
    );
  }

  Future<BranchEntity> createBranch(Map<String, dynamic> body) async {
    final response = await _api.post('/branches', body: body);
    final resp = jsonDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        resp['success'] == true)
      return BranchEntity.fromJson(resp['data']);
    // If server returned validation errors return them inside ApiException
    throw ApiException(
      'Failed to create branch',
      errors: resp is Map<String, dynamic> ? resp : null,
    );
  }

  Future<BranchEntity> updateBranch(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/branches/$id', body: body);
    final resp = jsonDecode(response.body);
    if (response.statusCode == 200 && resp['success'] == true)
      return BranchEntity.fromJson(resp['data']);
    throw ApiException(
      'Failed to update branch',
      errors: resp is Map<String, dynamic> ? resp : null,
    );
  }

  Future<bool> deleteBranch(int id) async {
    final response = await _api.delete('/branches/$id');
    final resp = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return resp['success'] == true;
    }
    throw ApiException(
      'Failed to delete branch',
      errors: resp is Map<String, dynamic> ? resp : null,
    );
  }

  Future<BranchEntity> getBranchById(int id) async {
    final response = await _api.get('/branches/$id');
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true)
      return BranchEntity.fromJson(body['data']);
    throw ApiException(
      'Failed to fetch branch',
      errors: body is Map<String, dynamic> ? body : null,
    );
  }

  Future<Map<String, dynamic>> getStatsOverview() async {
    final response = await _api.get('/branches/stats/overview');
    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true)
      return body['data'] as Map<String, dynamic>;
    throw ApiException(
      'Failed to load branch stats',
      errors: body is Map<String, dynamic> ? body : null,
    );
  }
}
