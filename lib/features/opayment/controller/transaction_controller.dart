// lib/features/transaction/controllers/transaction_controller.dart
import 'package:get/get.dart';
import 'package:sixam_mart/services/transaction_service.dart';

class TransactionController extends GetxController {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _recentTransactions = [];
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = false;
  String _selectedStatus = 'Semua';

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get selectedStatus => _selectedStatus;

  // Load recent transactions for dashboard (3 terakhir)
  Future<void> loadRecentTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    update();

    try {
      final response = await TransactionService.getRecentTransactions();
      
      if (response.success) {
        _recentTransactions = response.transactions;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Gagal memuat transaksi';
        _recentTransactions = [];
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _recentTransactions = [];
    }

    _isLoading = false;
    update();
  }

  // Load all transactions with pagination
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _transactions = [];
      _hasMore = false;
    }

    if (refresh) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    
    _errorMessage = null;
    update();

    try {
      final response = await TransactionService.getTransactionHistory(
        limit: 20,
        offset: _currentPage * 20,
        status: _selectedStatus == 'Semua' ? null : _selectedStatus,
      );

      if (response.success) {
        if (refresh) {
          _transactions = response.transactions;
        } else {
          _transactions.addAll(response.transactions);
        }
        
        _hasMore = response.hasMore;
        _currentPage++;
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Gagal memuat transaksi';
        if (refresh) {
          _transactions = [];
        }
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      if (refresh) {
        _transactions = [];
      }
    }

    _isLoading = false;
    _isLoadingMore = false;
    update();
  }

  // Filter by status
  void filterByStatus(String status) {
    _selectedStatus = status;
    loadTransactions(refresh: true);
  }

  // Load more transactions
  void loadMore() {
    if (!_isLoadingMore && _hasMore) {
      loadTransactions();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadRecentTransactions();
  }
}