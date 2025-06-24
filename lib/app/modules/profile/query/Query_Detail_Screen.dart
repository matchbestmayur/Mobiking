// lib/screens/query_detail_screen.dart
import 'dart:ui'; // Required for ImageFilter and BackdropFilter

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/query_getx_controller.dart'; // Corrected import
import '../../../data/QueryModel.dart'; // Ensure QueryModel.dart has ReplyModel if it's separate
import '../../../themes/app_theme.dart'; // Import AppColors and other theme elements

// QueryDetailScreen is now a GetView, giving direct access to the controller
class QueryDetailScreen extends GetView<QueryGetXController> {
  const QueryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final QueryModel? query = controller.selectedQuery;

      if (query == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Error', style: textTheme.titleLarge?.copyWith(color: AppColors.white)),
            backgroundColor: AppColors.darkPurple,
          ),
          body: Center(child: Text('Query not found or not selected.', style: textTheme.bodyLarge)),
        );
      }

      // Determine if the chat input should be shown
      // Chat box visible only if query is assigned
      final bool showChatInput = query.assignedTo != null && query.assignedTo!.isNotEmpty;
      // Rating/Review button visible only if query is resolved and not yet rated (hypothetically)
      // Assuming 'isRated' is a new field in QueryModel, or you check if rating is > 0
      final bool showRatingOption = query.status == 'resolved' && (query.rating == null || query.rating == 0);


      return Scaffold(
        backgroundColor: AppColors.neutralBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            query.title,
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          backgroundColor: AppColors.darkPurple,
          elevation: 0,
          actions: [
            // Show rating option if conditions are met
            if (showRatingOption)
              IconButton(
                icon: const Icon(Icons.star_rate_rounded, color: AppColors.accentNeon),
                tooltip: 'Rate this query',
                onPressed: () => _showRatingReviewModal(context, query.id),
              ),
            // The PopupMenuButton for status update has been removed from here.
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Query Details Card (Title, Message, Status, Timestamps, Assigned To)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            query.title,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            query.message,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: AppColors.textDark.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          // --- Show Query Status ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ${query.status}', // Display status
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green, // Get color based on status
                                ),
                              ),
                              // Display current rating if available
                              if (query.rating != null && query.rating! > 0)
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text(
                                      ' ${query.rating}',
                                      style: textTheme.labelSmall?.copyWith(color: AppColors.textDark),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 0.5, color: AppColors.primaryPurple), // Separator

                          // --- Show Complete Query Details: Raised At, Assigned To, Resolved At ---
                          _buildDetailRow(
                            textTheme,
                            'Raised At:',
                            DateFormat('MMM d, hh:mm a').format(query.raisedAt ?? query.createdAt), // Use raisedAt if available, fallback to createdAt
                          ),
                          _buildDetailRow(
                            textTheme,
                            'Assigned To:',
                            query.assignedTo != null && query.assignedTo!.isNotEmpty
                                ? query.assignedTo! // Display assignedTo if available
                                : 'Not yet assigned',
                          ),
                          if (query.status == 'resolved' && query.resolvedAt != null)
                            _buildDetailRow(
                              textTheme,
                              'Resolved At:',
                              DateFormat('MMM d, hh:mm a').format(query.resolvedAt!),
                            ),
                          if (query.rating != null && query.rating! > 0 && query.review != null && query.review!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Your Review:',
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  query.review!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.textDark.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Replies',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                        ),
                        child: Obx(() {
                          final replies = controller.selectedQuery?.replies ?? [];

                          if (replies.isEmpty) {
                            return Center(
                              child: Text(
                                'No replies yet. Start the conversation!',
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textDark.withOpacity(0.6)),
                              ),
                            );
                          }

                          return ListView.builder(
                            reverse: true,
                            itemCount: replies.length,
                            itemBuilder: (context, index) {
                              final reply = replies[replies.length - 1 - index];
                              final isUser = !reply.isAdmin;

                              return Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(14),
                                  constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                                  decoration: BoxDecoration(
                                    color: isUser ? AppColors.primaryPurple : AppColors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(15),
                                      topRight: const Radius.circular(15),
                                      bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(5),
                                      bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(15),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.textDark.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reply.replyText,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 15,
                                          color: isUser ? AppColors.white : AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        DateFormat('hh:mm a').format(reply.timestamp),
                                        style: textTheme.labelSmall?.copyWith(
                                          fontSize: 11,
                                          color: isUser ? AppColors.white.withOpacity(0.7) : AppColors.textLight.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Conditional Message text field ---
              if (showChatInput)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                          color: AppColors.darkPurple,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.attach_file_rounded,
                            color: AppColors.white.withOpacity(0.9),
                            size: 24,
                          ),
                          onPressed: () {
                            Get.snackbar(
                              'Attachment',
                              'Feature to add photo/video will be implemented here!',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.primaryPurple,
                              colorText: AppColors.white,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.replyInputController,
                          cursorColor: AppColors.primaryPurple,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textLight.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: AppColors.primaryPurple.withOpacity(0.4), width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textDark),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Obx(() =>
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: controller.isLoading ? AppColors.textLight : AppColors.accentNeon,
                            child: IconButton(
                              icon: controller.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                                  : const Icon(Icons.send, color: AppColors.white),
                              onPressed: controller.isLoading ? null : () async {
                                if (controller.replyInputController.text.trim().isNotEmpty) {
                                  await controller.replyToQuery(
                                    queryId: query.id,
                                    replyText: controller.replyInputController.text.trim(),
                                  );
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // --- Helper for displaying detail rows ---
  Widget _buildDetailRow(TextTheme textTheme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for labels for alignment
            child: Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- Rating and Review Modal ---
  void _showRatingReviewModal(BuildContext context, String queryId) {
    int _selectedRating = 0;
    final TextEditingController _reviewController = TextEditingController();

    Get.bottomSheet(
      Obx(() => // Use Obx to react to isLoading from controller
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Adjust for keyboard
          ),
          decoration: const BoxDecoration(
            color: AppColors.white, // Modal background
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take minimum space
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Rate and Review Query',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPurple,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Rating:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: controller.isLoading ? null : () {
                      // Using Get.find to access QueryGetXController for forceUpdate,
                      // this ensures the UI rebuilds for the rating selection.
                      final c = Get.find<QueryGetXController>();
                      _selectedRating = index + 1;
                      c.update(); // Force GetBuilder/Obx to rebuild if needed for rating stars
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Review (Optional):',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us about your experience...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.accentNeon, width: 2.0),
                  ),
                  filled: true,
                  fillColor: AppColors.neutralBackground,
                ),
                enabled: !controller.isLoading,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : () {
                    if (_selectedRating == 0) {
                      Get.snackbar('Error', 'Please select a rating.',
                          backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
                      return;
                    }
                    Get.back(); // Close modal first
                    controller.rateQuery(
                      queryId: queryId.toString(),
                      rating: _selectedRating,
                      review: _reviewController.text.trim().isNotEmpty ? _reviewController.text.trim() : null,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentNeon, // Use accent color for button
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : Text(
                    'Submit Rating',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
      isScrollControlled: true, // Allows the modal to take full height if needed by keyboard
    );
  }

// The helper methods below are no longer needed as their logic is integrated
// or they were previously unused.
// Widget _buildSectionHeader(String title, TextTheme textTheme) { ... }
// Widget _buildQueryCard(...) { ... } // Replaced by direct implementation in build method
}