import 'package:flutter/foundation.dart';

import '../../domain/entities/branch_entity.dart';
import '../../services/branch_service.dart';

class BranchProvider extends ChangeNotifier {
  final BranchService _service = BranchService();

  List<BranchEntity> _branches = [];
  List<dynamic> _companies = [];
  int _currentPage = 1;
  int _limit = 9999;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _search = '';
  int? _companyFilter;
  bool? _isMainFilter;

  List<BranchEntity> get branches => _branches;
  List<dynamic> get companies => _companies;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int? get companyFilter => _companyFilter;
  bool? get isMainFilter => _isMainFilter;

  Future<void> fetchCompaniesDropdown() async {
    try {
      _companies = await _service.getCompaniesDropdown();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchBranches({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      if (refresh) {
        _currentPage = 1;
        _branches = [];
        _hasMore = true;
      }

      final resp = await _service.getBranches(
        page: _currentPage,
        limit: _limit,
        search: _search.isEmpty ? null : _search,
        companyId: _companyFilter,
        isMain: _isMainFilter,
      );
      final data = resp['branches'] as List<BranchEntity>;
      final pagination = resp['pagination'] as Map<String, dynamic>;

      _branches.addAll(data);
      _totalPages = pagination['total_pages'] ?? 1;
      _hasMore = _currentPage < _totalPages;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (!_hasMore || _isLoading) return;
    _currentPage += 1;
    await fetchBranches();
  }

  Future<void> search(String query) async {
    _search = query;
    _currentPage = 1;
    _branches = [];
    await fetchBranches(refresh: true);
  }

  Future<void> setCompanyFilter(int? companyId) async {
    _companyFilter = companyId;
    _currentPage = 1;
    _branches = [];
    await fetchBranches(refresh: true);
  }

  Future<void> setIsMainFilter(bool? isMain) async {
    _isMainFilter = isMain;
    _currentPage = 1;
    _branches = [];
    await fetchBranches(refresh: true);
  }

  Future<BranchEntity> createBranch(Map<String, dynamic> body) async {
    final branch = await _service.createBranch(body);
    _branches.insert(0, branch);
    notifyListeners();
    return branch;
  }

  Future<BranchEntity> updateBranch(int id, Map<String, dynamic> body) async {
    final branch = await _service.updateBranch(id, body);
    final idx = _branches.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _branches[idx] = branch;
      notifyListeners();
    }
    return branch;
  }

  Future<bool> deleteBranch(int id) async {
    final ok = await _service.deleteBranch(id);
    if (ok) {
      _branches.removeWhere((b) => b.id == id);
      notifyListeners();
    }
    return ok;
  }
}
