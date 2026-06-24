import 'dart:convert';
import '../data/models/special_offer_model.dart';
import 'api_service.dart';

class SpecialOfferService {
  final ApiService _api = ApiService();

  Future<List<SpecialOfferModel>> getOffers({bool? isActive, int? statusId}) async {
    String query = '';
    if (isActive != null) query += 'is_active=$isActive&';
    if (statusId != null) query += 'status_id=$statusId&';
    
    final response = await _api.get('/special-offers?$query');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final data = body['data'] as List;
        return data.map((e) => SpecialOfferModel.fromJson(e)).toList();
      }
    }
    throw Exception('Failed to load special offers');
  }

  Future<SpecialOfferModel> getOfferById(int id) async {
    final response = await _api.get('/special-offers/$id');
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return SpecialOfferModel.fromJson(body['data']);
      }
    }
    throw Exception('Failed to load special offer');
  }

  Future<SpecialOfferModel> createOffer(Map<String, dynamic> body) async {
    final response = await _api.post('/special-offers', body: body);
    final resp = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (resp['success'] == true) {
        return SpecialOfferModel.fromJson(resp['data']);
      }
      throw Exception(resp['message'] ?? resp['error'] ?? 'Failed to create offer');
    }
    throw Exception(resp['message'] ?? resp['error'] ?? 'Failed to create offer: ${response.statusCode}');
  }

  Future<bool> updateOffer(int id, Map<String, dynamic> body) async {
    final response = await _api.put('/special-offers/$id', body: body);
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      return resp['success'] == true;
    }
    throw Exception('Failed to update offer: ${response.statusCode}');
  }

  Future<bool> deleteOffer(int id) async {
    final response = await _api.delete('/special-offers/$id');
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      return resp['success'] == true;
    }
    throw Exception('Failed to delete offer: ${response.statusCode}');
  }
}
