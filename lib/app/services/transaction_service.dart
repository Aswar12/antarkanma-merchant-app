import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import '../data/providers/transaction_provider.dart';
import '../data/models/transaction_model.dart';
import '../data/enums/order_item_status.dart';
import '../widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart';

class TransactionService extends GetxService {
  final TransactionProvider _transactionProvider = TransactionProvider();

  void _handleError(dio.DioException error) {
    String message;
    switch (error.response?.statusCode) {
      case 401:
        message = 'Sesi anda telah berakhir. Silakan login kembali.';
        break;
      case 422:
        message = error.response?.data?['meta']?['message'] ?? 'Validasi gagal';
        break;
      case 403:
        message = 'Anda tidak memiliki akses ke halaman ini.';
        break;
      case 404:
        message = 'Data tidak ditemukan.';
        break;
      case 500:
        message = 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        break;
      default:
        message = error.message ?? 'Terjadi kesalahan yang tidak diketahui';
    }

    CustomSnackbarX.showError(
      title: 'Error',
      message: message,
      position: SnackPosition.BOTTOM,
    );
    throw Exception(message);
  }

  Future<TransactionModel?> createTransaction(
      Map<String, dynamic> transactionData) async {
    try {
      debugPrint('\n=== TransactionService: Creating Transaction ===');
      debugPrint('Transaction Data: $transactionData');

      final response =
          await _transactionProvider.createTransaction(transactionData);
      debugPrint('\n=== TransactionService: Response Received ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['meta']?['status'] == 'success') {
          try {
            final transactionJson = responseData['data'];
            debugPrint(
                '\n=== TransactionService: Creating TransactionModel ===');
            debugPrint('Transaction JSON: $transactionJson');

            if (transactionJson == null) {
              throw Exception('Transaction data is null');
            }

            final transaction = TransactionModel.fromJson(transactionJson);
            debugPrint('\n=== TransactionService: Transaction Created ===');
            debugPrint('Transaction ID: ${transaction.id}');
            debugPrint('Order ID: ${transaction.orderId}');
            debugPrint('Total Price: ${transaction.totalPrice}');
            debugPrint('Items Count: ${transaction.items.length}');

            return transaction;
          } catch (parseError, stackTrace) {
            debugPrint('\n=== Error Parsing Transaction Data ===');
            debugPrint('Parse Error: $parseError');
            debugPrint('Stack Trace: $stackTrace');
            debugPrint('Raw Data: ${responseData['data']}');

            CustomSnackbarX.showError(
              title: 'Error',
              message: 'Terjadi kesalahan saat memproses data transaksi',
              position: SnackPosition.BOTTOM,
            );
            return null;
          }
        } else {
          final message =
              responseData?['meta']?['message'] ?? 'Gagal membuat transaksi';
          CustomSnackbarX.showError(
            title: 'Error',
            message: message,
            position: SnackPosition.BOTTOM,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('\n=== TransactionService: Error Creating Transaction ===');
      debugPrint('Error: $e');
      CustomSnackbarX.showError(
        title: 'Error',
        message: 'Gagal membuat transaksi: $e',
        position: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<List<TransactionModel>> getTransactions({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _transactionProvider.getTransactions(
        status: status,
        page: page,
        pageSize: pageSize,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> transactionsData = response.data['data'];
        debugPrint('\n=== Getting Transactions ===');
        debugPrint('Found ${transactionsData.length} transactions');

        final transactions = transactionsData
            .map((json) {
              try {
                return TransactionModel.fromJson(json);
              } catch (e, stackTrace) {
                debugPrint('Error parsing transaction: $e');
                debugPrint('Stack trace: $stackTrace');
                debugPrint('JSON data: $json');
                return null;
              }
            })
            .where((t) => t != null)
            .cast<TransactionModel>()
            .toList();

        debugPrint('Successfully parsed ${transactions.length} transactions');
        return transactions;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final response = await _transactionProvider.getTransactionById(id);

      if (response.statusCode == 200 && response.data['data'] != null) {
        final transactionJson = response.data['data'];
        debugPrint('\n=== Getting Transaction By ID ===');
        debugPrint('Transaction data: $transactionJson');

        final transaction = TransactionModel.fromJson(transactionJson);
        debugPrint('Successfully parsed transaction ${transaction.id}');
        return transaction;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      return null;
    }
  }

  Future<bool> cancelTransaction(String transactionId) async {
    try {
      debugPrint('\n=== TransactionService: Canceling Transaction ===');
      debugPrint('Transaction ID: $transactionId');

      final response =
          await _transactionProvider.cancelTransaction(transactionId);

      if (response.statusCode == 200) {
        debugPrint('Successfully canceled transaction');
        return true;
      }

      final message =
          response.data?['meta']?['message'] ?? 'Failed to cancel transaction';
      CustomSnackbarX.showError(
        title: 'Error',
        message: message,
        position: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      debugPrint('Error canceling transaction: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTransactionsByMerchant(
    String merchantId, {
    int? page = 1,
    int? limit = 10,
    String? status,
    String? merchantApproval,
  }) async {
    try {
      debugPrint('\n=== Getting Merchant Orders ===');
      debugPrint('Merchant ID: $merchantId');
      debugPrint('Page: $page');
      debugPrint('Limit: $limit');
      debugPrint('Status Filter: $status');
      debugPrint('Merchant Approval: $merchantApproval');

      final response = await _transactionProvider.getTransactionsByMerchant(
        merchantId,
        page: page ?? 1,
        limit: limit ?? 10,
        status: status,
        merchantApproval: merchantApproval,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 &&
          response.data['meta']?['status'] == 'success') {
        final data = response.data['data'];
        if (data != null) {
          final transactions = data['transactions'];

          // Handle status_counts as List or Map
          final defaultCounts = {
            OrderItemStatus.pending.value: 0,
            OrderItemStatus.waitingApproval.value: 0,
            OrderItemStatus.processing.value: 0,
            OrderItemStatus.ready.value: 0,
            OrderItemStatus.pickedUp.value: 0,
            OrderItemStatus.completed.value: 0,
            OrderItemStatus.canceled.value: 0,
          };

          Map<String, int> mergedStatusCounts =
              Map<String, int>.from(defaultCounts);

          // Get status_counts from response
          final statusCountsData = data['status_counts'];
          if (statusCountsData != null) {
            if (statusCountsData is List) {
              // If it's a list, process each item
              for (var item in statusCountsData) {
                if (item is Map) {
                  String? status = item['status']?.toString().toUpperCase();
                  int count =
                      item['count'] is num ? (item['count'] as num).toInt() : 0;
                  if (status != null && defaultCounts.containsKey(status)) {
                    mergedStatusCounts[status] = count;
                  }
                }
              }
            } else if (statusCountsData is Map) {
              // If it's a map, process directly
              statusCountsData.forEach((key, value) {
                String status = key.toString().toUpperCase();
                if (defaultCounts.containsKey(status)) {
                  mergedStatusCounts[status] = value is num ? value.toInt() : 0;
                }
              });
            }
          }

          debugPrint('\n=== Status Counts ===');
          mergedStatusCounts.forEach((key, value) {
            debugPrint('$key: $value');
          });

          return {
            'transactions': transactions,
            'status_counts': mergedStatusCounts,
          };
        }
      }

      debugPrint('Failed to get merchant orders');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error getting merchant orders: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTransactionSummaryByMerchant(
      String merchantId) async {
    try {
      final response = await _transactionProvider
          .getTransactionSummaryByMerchant(merchantId);
      debugPrint('\n=== Getting Transaction Summary ===');
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 200 &&
          response.data['meta']?['status'] == 'success') {
        final data = response.data['data'];
        if (data != null) {
          final statistics = data['statistics'] ?? {};
          final ordersData = data['orders'] ?? {};

          return {
            'statistics': {
              'total_orders': statistics['total_orders'] ?? 0,
              'pending_orders': statistics['pending_orders'] ?? 0,
              'processing_orders': statistics['processing_orders'] ?? 0,
              'readytopickup_orders': statistics['readytopickup_orders'] ?? 0,
              'completed_orders': statistics['completed_orders'] ?? 0,
              'canceled_orders': statistics['canceled_orders'] ?? 0,
              'total_revenue':
                  (statistics['total_revenue'] as num?)?.toDouble() ?? 0.0,
            },
            'orders': {
              'pending': _parseOrdersList(ordersData['pending']),
              'processing': _parseOrdersList(ordersData['processing']),
              'readytopickup': _parseOrdersList(ordersData['readytopickup']),
              'completed': _parseOrdersList(ordersData['completed']),
              'canceled': _parseOrdersList(ordersData['canceled']),
            },
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting transaction summary: $e');
      return null;
    }
  }

  List<TransactionModel> _parseOrdersList(List<dynamic>? ordersList) {
    if (ordersList == null) return [];
    return ordersList
        .map((json) {
          try {
            return TransactionModel.fromJson(json);
          } catch (e) {
            debugPrint('Error parsing order in summary: $e');
            debugPrint('Order JSON: $json');
            return null;
          }
        })
        .where((order) => order != null)
        .cast<TransactionModel>()
        .toList();
  }

  // New methods for merchant order flow
  Future<bool> approveOrder(String orderId) async {
    try {
      debugPrint('\n=== TransactionService: Approving Order ===');
      debugPrint('Order ID: $orderId');

      final response = await _transactionProvider.approveOrder(orderId);

      if (response.statusCode == 200 &&
          response.data['meta']?['status'] == 'success') {
        debugPrint('Successfully approved order');
        return true;
      }

      final message = response.data?['meta']?['message'] ?? 'Failed to approve order';
      CustomSnackbarX.showError(
        title: 'Error',
        message: message,
        position: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      debugPrint('Error approving order: $e');
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    try {
      debugPrint('\n=== TransactionService: Rejecting Order ===');
      debugPrint('Order ID: $orderId');
      if (reason != null) debugPrint('Reason: $reason');

      final response = await _transactionProvider.rejectOrder(orderId, reason: reason);

      if (response.statusCode == 200 &&
          response.data['meta']?['status'] == 'success') {
        debugPrint('Successfully rejected order');
        return true;
      }

      final message = response.data?['meta']?['message'] ?? 'Failed to reject order';
      CustomSnackbarX.showError(
        title: 'Error',
        message: message,
        position: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      debugPrint('Error rejecting order: $e');
      return false;
    }
  }

  Future<bool> markOrderReady(String orderId) async {
    try {
      debugPrint('\n=== TransactionService: Marking Order as Ready ===');
      debugPrint('Order ID: $orderId');

      final response = await _transactionProvider.markOrderReady(orderId);

      if (response.statusCode == 200 &&
          response.data['meta']?['status'] == 'success') {
        debugPrint('Successfully marked order as ready');
        return true;
      }

      final message = response.data?['meta']?['message'] ?? 'Failed to mark order as ready';
      CustomSnackbarX.showError(
        title: 'Error',
        message: message,
        position: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      debugPrint('Error marking order as ready: $e');
      return false;
    }
  }
}
