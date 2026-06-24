import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/storage_util.dart';
import '../../data/models/job_vacancy.dart';
import '../../services/api_service.dart';

class JobProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<JobVacancyModel> _allJobs = [];
  List<JobVacancyModel> _myJobs = [];
  List<JobApplicationModel> _currentJobApplications = [];
  
  bool _isLoading = false;
  String? _error;

  List<JobVacancyModel> get allJobs => _allJobs;
  List<JobVacancyModel> get myJobs => _myJobs;
  List<JobApplicationModel> get currentJobApplications => _currentJobApplications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear errors
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Fetch all active jobs
  Future<void> fetchAllJobs({String? category, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = '/jobs';
      List<String> queryParams = [];
      if (category != null && category.isNotEmpty) {
        queryParams.add('category=${Uri.encodeComponent(category)}');
      }
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search)}');
      }
      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        _allJobs = (body['data'] as List)
            .map((item) => JobVacancyModel.fromJson(item))
            .toList();
      } else {
        _error = body['message'] ?? 'Failed to fetch jobs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch jobs created by the current user
  Future<void> fetchMyJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/jobs/my');
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        _myJobs = (body['data'] as List)
            .map((item) => JobVacancyModel.fromJson(item))
            .toList();
      } else {
        _error = body['message'] ?? 'Failed to fetch your jobs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new job vacancy
  Future<bool> createJob(Map<String, dynamic> jobData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/jobs', body: jobData);
      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        await fetchAllJobs();
        await fetchMyJobs();
        return true;
      } else {
        _error = body['message'] ?? 'Failed to post job vacancy';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a job vacancy
  Future<bool> updateJob(int jobId, Map<String, dynamic> jobData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put('/jobs/$jobId', body: jobData);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await fetchAllJobs();
        await fetchMyJobs();
        return true;
      } else {
        _error = body['message'] ?? 'Failed to update job';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete/Remove a job vacancy
  Future<bool> deleteJob(int jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/jobs/$jobId');
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await fetchAllJobs();
        await fetchMyJobs();
        return true;
      } else {
        _error = body['message'] ?? 'Failed to delete job';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload document for job application
  Future<String?> uploadDocument(Uint8List fileBytes, String fileName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = StorageUtil.getToken();
      final url = Uri.parse('${AppConstants.baseUrl}/upload');
      
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      String? mimeType = lookupMimeType(fileName) ?? 'application/pdf';

      var multipartFile = http.MultipartFile.fromBytes(
        'photo', // Use default single photo upload key
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return body['data']['url']; // Return uploaded static URL
      } else {
        _error = body['message'] ?? 'Failed to upload document';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply to a job vacancy
  Future<bool> applyToJob(int jobId, {String? coverLetter, String? documentUrl}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/jobs/$jobId/apply',
        body: {
          'cover_letter': coverLetter,
          'document_url': documentUrl,
        },
      );
      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        return true;
      } else {
        _error = body['message'] ?? 'Failed to submit application';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get applications for own job vacancy
  Future<void> fetchJobApplications(int jobId) async {
    _isLoading = true;
    _error = null;
    _currentJobApplications = [];
    notifyListeners();

    try {
      final response = await _apiService.get('/jobs/$jobId/applications');
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        _currentJobApplications = (body['data'] as List)
            .map((item) => JobApplicationModel.fromJson(item))
            .toList();
      } else {
        _error = body['message'] ?? 'Failed to fetch applications';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
