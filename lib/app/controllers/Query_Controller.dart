// lib/controllers/query_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../data/QueryModel.dart';
import '../modules/profile/query/Query_Detail_Screen.dart';

class QueryController extends GetxController {
  final Uuid _uuid = Uuid();

  // Reactive list of all queries
  final RxList<QueryModel> queries = <QueryModel>[].obs;

  // Reactive variable for the currently selected query for detail view
  final Rx<QueryModel?> selectedQuery = Rx<QueryModel?>(null);

  // StreamController for real-time replies in QueryDetailScreen
  // This will emit the entire list of replies whenever a new one is added
  final StreamController<List<ReplyModel>> _replyStreamController =
  StreamController<List<ReplyModel>>.broadcast();

  Stream<List<ReplyModel>> get replyStream => _replyStreamController.stream;

  @override
  void onInit() {
    super.onInit();
    // Simulate fetching initial queries
    _fetchDummyQueries();
  }

  @override
  void onClose() {
    _replyStreamController.close();
    super.onClose();
  }

  // Simulate fetching queries from a backend
  Future<void> _fetchDummyQueries() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    queries.value = [
      QueryModel(
        id: _uuid.v4(),
        title: 'Issue with recent order #123',
        message: 'My order has been delayed for 3 days. What is the status?',
        userEmail: 'xyz2011@gmail.com',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        replies: [
          ReplyModel(id: _uuid.v4(), userId: 'xyz2011@gmail.com', replyText: 'Still waiting for updates.', timestamp: DateTime.now().subtract(const Duration(days: 4))),
          ReplyModel(id: _uuid.v4(), userId: 'admin', replyText: 'We are looking into this for you. Please allow 24 hours for an update.', timestamp: DateTime.now().subtract(const Duration(days: 3)), isAdmin: true),
        ],
        isRead: true,
      ),
      QueryModel(
        id: _uuid.v4(),
        title: 'Product defect - iPhone 15 Pro Max',
        message: 'The screen of my new iPhone 15 Pro Max has a dead pixel. How do I initiate a return?',
        userEmail: 'xyz2011@gmail.com',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        replies: [
          ReplyModel(id: _uuid.v4(), userId: 'admin', replyText: 'Please send us a video of the issue. We will guide you through the return process.', timestamp: DateTime.now().subtract(const Duration(days: 1)), isAdmin: true),
        ],
      ),
      QueryModel(
        id: _uuid.v4(),
        title: 'Regarding warranty claim for headphones',
        message: 'My headphones stopped working after 3 months. Is it covered under warranty?',
        userEmail: 'xyz2011@gmail.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];
    // Emit replies for the first query if it's selected (though it won't be initially)
    if (selectedQuery.value != null) {
      _replyStreamController.add(selectedQuery.value!.replies);
    }
  }

  // Add a new query
  void addNewQuery(String title, String message, String userEmail) {
    final newQuery = QueryModel(
      id: _uuid.v4(),
      title: title,
      message: message,
      userEmail: userEmail,
      isRead: false, // Newly created query is initially unread (by admin)
    );
    queries.add(newQuery);
    queries.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by creation date (latest first)
    Get.back(); // Close the dialog
    Get.snackbar(
      'Success',
      'Your query has been raised!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  // Select a query to view its details
  void selectQuery(QueryModel query) {
    selectedQuery.value = query;
    selectedQuery.value!.isRead = true; // Mark as read when selected
    queries.refresh(); // Update the UI for the read status
    _replyStreamController.add(query.replies); // Initialize the stream with existing replies
    Get.to(() => QueryDetailScreen());
  }

  // Add a reply to the currently selected query
  void addReply(String replyText, {bool isAdmin = false}) {
    if (selectedQuery.value != null && replyText.trim().isNotEmpty) {
      final newReply = ReplyModel(
        id: _uuid.v4(),
        userId: isAdmin ? 'admin' : selectedQuery.value!.userEmail, // Dummy user for client
        replyText: replyText,
        isAdmin: isAdmin,
      );
      selectedQuery.value!.replies.add(newReply);
      selectedQuery.value!.isRead = false; // Mark as unread by other party
      queries.refresh(); // Update the list in QueriesScreen
      _replyStreamController.add(selectedQuery.value!.replies); // Emit updated replies to stream
    }
  }

  // Clear selected query when leaving detail screen
  void clearSelectedQuery() {
    selectedQuery.value = null;
  }
}