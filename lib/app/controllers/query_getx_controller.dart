// Path: lib/controllers/query_getx_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/QueryModel.dart';
// import '../modules/profile/query/Query_Detail_Screen.dart'; // This import is usually not needed here
import '../services/query_service.dart';
import '../themes/app_theme.dart'; // Import AppColors for getStatusColor

class QueryGetXController extends GetxController {
  final RxList<QueryModel> _myQueries = <QueryModel>[].obs;
  List<QueryModel> get myQueries => _myQueries.value;

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _errorMessage = RxString('');
  String? get errorMessage => _errorMessage.value.isEmpty ? null : _errorMessage.value;

  final Rx<QueryModel?> _selectedQuery = Rx<QueryModel?>(null);
  QueryModel? get selectedQuery => _selectedQuery.value;

  late final TextEditingController _replyInputController;
  TextEditingController get replyInputController => _replyInputController;

  final QueryService _queryService = Get.find<QueryService>();
  final GetStorage _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _replyInputController = TextEditingController();
    _setAuthTokenFromStorage();
    fetchMyQueries();
  }

  @override
  void onClose() {
    _replyInputController.dispose();
    super.onClose();
  }

  void _setAuthTokenFromStorage() {
    final String? accessToken = _box.read('accessToken');
    if (accessToken != null && accessToken.isNotEmpty) {
      _queryService.setAuthToken(accessToken);
      print('QueryGetXController: Access token loaded and set for QueryService.');
    } else {
      print('QueryGetXController: No access token found in GetStorage. Authenticated calls might fail.');
      Get.snackbar(
        'Authentication Missing',
        'No access token found. Please log in.',
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  String _getFriendlyErrorMessage(dynamic e, String defaultMessage) {
    String message = defaultMessage;
    if (e is Exception) {
      final String errorString = e.toString();
      // Updated regex to reflect removal of status update related messages
      final regex = RegExp(r'Exception: Failed to (?:raise|load|rate|reply to|get) query: (.*)');
      final match = regex.firstMatch(errorString);
      if (match != null && match.groupCount >= 1) {
        message = match.group(1)!;
      } else {
        message = errorString;
      }
    } else {
      message = e.toString();
    }
    return message.trim().isEmpty ? defaultMessage : message;
  }

  /// Helper method to find and update a query in the _myQueries list.
  /// This ensures the list remains reactive and correctly reflects changes.
  void _updateQueryInList(QueryModel updatedQuery) {
    // Find the index of the existing query by its ID
    final int index = _myQueries.indexWhere((q) => q.id == updatedQuery.id);

    if (index != -1) {
      // If found, replace the old query object with the updated one
      _myQueries[index] = updatedQuery;
      // Trigger a UI update for the list if needed, although direct assignment to RxList element usually triggers it.
    } else {
      // Optionally, if the updatedQuery somehow wasn't in the list, add it.
      // This case might indicate a logic error or a new query being returned.
      _myQueries.add(updatedQuery);
      print('Warning: Updated query not found in list, added instead. ID: ${updatedQuery.id}');
    }

    // If the updated query is also the currently selected query in the detail screen, update it.
    // This will automatically refresh the QueryDetailScreen if it's observing _selectedQuery.
    if (_selectedQuery.value?.id == updatedQuery.id) {
      _selectedQuery.value = updatedQuery;
    }
  }

  Future<void> fetchMyQueries() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final queries = await _queryService.getMyQueries();
      _myQueries.value = queries;
      Get.snackbar(
        'Success',
        'Queries fetched successfully!',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
      print('QueryGetXController: Fetched queries: ${queries.map((q) => '${q.title} (ID: ${q.id}, isRead: ${q.isRead})').join(', ')}');
    } catch (e) {
      final userFriendlyMessage = _getFriendlyErrorMessage(e, 'Error fetching queries.');
      _errorMessage.value = userFriendlyMessage;
      Get.snackbar('Error', userFriendlyMessage, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Error fetching queries: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> raiseQuery({
    required String title,
    required String message,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final newQuery = await _queryService.raiseQuery(
        title: title,
        message: message,
      );
      _myQueries.insert(0, newQuery);
      Get.snackbar('Success', 'Query raised successfully! ID: ${newQuery.id}', backgroundColor: Colors.green.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: New query raised: ${newQuery.toJson()}');
    } catch (e) {
      final userFriendlyMessage = _getFriendlyErrorMessage(e, 'Error raising query.');
      _errorMessage.value = userFriendlyMessage;
      Get.snackbar('Error', userFriendlyMessage, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Error raising query: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> rateQuery({
    required String queryId,
    required int rating,
    String? review,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final updatedQuery = await _queryService.rateQuery(
        queryId: queryId,
        rating: rating,
        review: review,
      );
      _updateQueryInList(updatedQuery); // Use the helper
      Get.snackbar('Success', 'Query rated successfully! ID: ${updatedQuery.id}', backgroundColor: Colors.green.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Query rated: ${updatedQuery.toJson()}');
    } catch (e) {
      final userFriendlyMessage = _getFriendlyErrorMessage(e, 'Error rating query.');
      _errorMessage.value = userFriendlyMessage;
      Get.snackbar('Error', userFriendlyMessage, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Error rating query: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> replyToQuery({
    required String queryId,
    required String replyText,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final updatedQuery = await _queryService.replyToQuery(
        queryId: queryId,
        replyText: replyText,
      );
      _updateQueryInList(updatedQuery); // Use the helper
      _replyInputController.clear();
      Get.snackbar('Success', 'Replied to query successfully! ID: ${updatedQuery.id}', backgroundColor: Colors.green.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Replied to query: ${updatedQuery.toJson()}');
    } catch (e) {
      final userFriendlyMessage = _getFriendlyErrorMessage(e, 'Error replying to query.');
      _errorMessage.value = userFriendlyMessage;
      Get.snackbar('Error', userFriendlyMessage, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Error replying to query: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // New method to mark a query as read on the backend
  Future<void> markQueryAsRead(String queryId) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final updatedQuery = await _queryService.markQueryAsRead(queryId);
      // Update the query in the local list and selected query
      _updateQueryInList(updatedQuery); // Use the helper
      Get.snackbar('Success', 'Query marked as read!', backgroundColor: Colors.green.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Query ID $queryId marked as read.');
    } catch (e) {
      final userFriendlyMessage = _getFriendlyErrorMessage(e, 'Error marking query as read.');
      _errorMessage.value = userFriendlyMessage;
      Get.snackbar('Error', userFriendlyMessage, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
      print('QueryGetXController: Error marking query as read: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // The `updateQueryStatus` method has been removed from here.

  void selectQuery(QueryModel query) {
    _selectedQuery.value = query;
  }

  void clearSelectedQuery() {
    _selectedQuery.value = null;
  }

  // --- NEW: getStatusColor method added ---
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.info; // Blue for open
      case 'pending_reply':
        return AppColors.accentOrange; // Orange for pending reply
      case 'resolved':
        return AppColors.success; // Green for resolved
      case 'closed':
        return AppColors.textLight; // Grey for closed
      default:
        return AppColors.textLight; // Default to grey for unknown
    }
  }
// --- END NEW ---
}