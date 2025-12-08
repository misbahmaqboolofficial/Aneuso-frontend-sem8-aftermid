import 'package:flutter/foundation.dart';

import '../../domain/entities/company_entity.dart';
import '../../domain/entities/master_type_entity.dart';
import '../../services/company_service.dart';

class CompanyProvider with ChangeNotifier {
  final CompanyService _service = CompanyService();

  List<CompanyEntity> _companies = [];
  bool _isLoading = false;
  String? _error;

  // Pagination/search
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;
  bool _hasMore = true;
  String _searchQuery = '';

  // Dropdown types
  List<MasterTypeEntity> _companyTypes = [];
  List<MasterTypeEntity> _businessTypes = [];
  List<MasterTypeEntity> _wasteTypes = [];

  List<CompanyEntity> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  List<MasterTypeEntity> get companyTypes => _companyTypes;
  List<MasterTypeEntity> get businessTypes => _businessTypes;
  List<MasterTypeEntity> get wasteTypes => _wasteTypes;

  Future<void> fetchCompanies({int page = 1, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getCompaniesPage(
        page: page,
        limit: _limit,
        search: search,
      );
      final companies = (result['companies'] as List).cast<CompanyEntity>();
      final pagination = result['pagination'] as Map<String, dynamic>?;

      if (page == 1) {
        _companies = companies;
      } else {
        _companies.addAll(companies);
      }

      if (pagination != null) {
        _totalPages = pagination['pages'] ?? 1;
        _currentPage = pagination['page'] ?? page;
        _hasMore = _currentPage < _totalPages;
      } else {
        _hasMore = companies.length >= _limit;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _isLoading) return;
    await fetchCompanies(page: _currentPage + 1, search: _searchQuery);
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchCompanies(page: 1, search: query);
  }

  Future<void> fetchTypes() async {
    try {
      final companyTypesRaw = await _service.getCompanyTypes();
      _companyTypes = companyTypesRaw
          .map((e) => MasterTypeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore errors for individual lists
    }

    try {
      final businessTypesRaw = await _service.getBusinessTypes();
      _businessTypes = businessTypesRaw
          .map((e) => MasterTypeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {}

    try {
      final wasteTypesRaw = await _service.getWasteTypes();
      _wasteTypes = wasteTypesRaw
          .map((e) => MasterTypeEntity.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {}

    notifyListeners();
  }

  Future<bool> createCompany(Map<String, dynamic> body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final created = await _service.createCompany(body);
      _companies.insert(0, created);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCompany(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _service.deleteCompany(id);
      if (success) {
        _companies.removeWhere((c) => c.id == id);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCompany(int id, Map<String, dynamic> body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _service.updateCompany(id, body);
      final index = _companies.indexWhere((c) => c.id == id);
      if (index != -1) {
        _companies[index] = updated;
      } else {
        // if not found, insert at top
        _companies.insert(0, updated);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
