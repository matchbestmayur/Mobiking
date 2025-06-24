// lib/screens/queries_screen.dart
import 'dart:ui'; // Make sure this is imported

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/query_getx_controller.dart'; // Corrected import to QueryGetXController
import '../../../data/QueryModel.dart'; // Use QueryModel from your manual JSON models
import '../../../themes/app_theme.dart'; // Import your AppColors and AppTheme
import 'AboutUsDialog.dart'; // Assuming this exists
import 'FaqDialog.dart';     // Assuming this exists


import 'Raise_query.dart';
import 'query_detail_screen.dart'; // <--- NEW: Import the QueryDetailScreen

class QueriesScreen extends StatefulWidget {
  const QueriesScreen({super.key});

  @override
  State<QueriesScreen> createState() => _QueriesScreenState();
}

class _QueriesScreenState extends State<QueriesScreen> {
  // Get the instance of your QueryGetXController
  // Get.put() should ideally be done once in main.dart or a binding
  // to ensure a single instance and proper lifecycle management.
  // For simplicity in a single screen, it's often placed here for direct access.
  final QueryGetXController queryController = Get.put(QueryGetXController());
  final TextEditingController _quickQueryInputController = TextEditingController();

  @override
  void dispose() {
    _quickQueryInputController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  // Added a method to show the Raise Query Dialog
  void _showRaiseQueryDialog() {
    Get.dialog(
      const RaiseQueryDialog(), // onAddQuery is no longer needed as dialog handles GetX call internally
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the TextTheme from the current theme
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Light background for the overall screen
      body: CustomScrollView(
        slivers: [
          // Top Section: 'Talk with Support' and Quick Input
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            snap: false,
            elevation: 0,
            backgroundColor: AppColors.neutralBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPurple.withOpacity(0.08),
                      AppColors.primaryPurple.withOpacity(0.01),
                      AppColors.white.withOpacity(0.0), // Use AppColors.white
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 90.0, 24.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talk with Support',
                        // Use headlineLarge and override color if necessary
                        style: textTheme.headlineLarge?.copyWith(
                          fontSize: 30, // Override if AppTheme's headlineLarge is not 30
                          fontWeight: FontWeight.bold, // Ensure bold remains
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Prompt/Input Field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white, // Use AppColors.white
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textDark.withOpacity(0.08), // Use AppColors for consistency
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _quickQueryInputController,
                                decoration: InputDecoration(
                                  hintText: 'Ask a quick question...',
                                  // Use bodyMedium and override color/opacity
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textLight.withOpacity(0.7),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                // Use bodyMedium style
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 16, // Override to 16 if bodyMedium is different
                                  color: AppColors.textDark,
                                ),
                                cursorColor: AppColors.primaryPurple,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Icon(Icons.mic, color: AppColors.textLight.withOpacity(0.8)),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                if (_quickQueryInputController.text.isNotEmpty) {
                                  // This is a quick question, not a formal query to the backend
                                  Get.snackbar(
                                    'Quick Question',
                                    'Sent: "${_quickQueryInputController.text}"',
                                    backgroundColor: AppColors.primaryPurple,
                                    colorText: AppColors.white,
                                  );
                                  _quickQueryInputController.clear();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accentNeon,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Actions Section (Now with Glassmorphic background)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                        ),
                        padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              // Use titleLarge and override color if necessary
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 20, // Override if AppTheme's titleLarge is not 20
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  context,
                                  icon: Icons.message_outlined,
                                  label: 'Raise Query',
                                  onTap: _showRaiseQueryDialog, // Use the new method
                                ),
                                _buildActionButton(
                                  context,
                                  icon: Icons.lightbulb_outline,
                                  label: 'View \n FAQs',
                                  onTap: () {
                                    /* showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const FaqDialog(); // Assuming FaqDialog doesn't need TextEditingController directly
                                    },
                                  );*/
                                  },
                                ),
                                _buildActionButton(
                                  context,
                                  icon: Icons.contact_support_outlined,
                                  label: 'About \n Us',
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AboutUsDialog();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Previous Queries Section (Now with contrasting Glassmorphic effect)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 25.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Previous Queries',
                                  // Use titleLarge and override color if necessary
                                  style: textTheme.titleLarge?.copyWith(
                                    fontSize: 20, // Override if AppTheme's titleLarge is not 20
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                // Add a refresh button for queries
                                Obx(
                                      () => IconButton(
                                    icon: const Icon(Icons.refresh, color: AppColors.textLight),
                                    onPressed: queryController.isLoading ? null : queryController.fetchMyQueries,
                                    tooltip: 'Refresh Queries',
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Container for the query list
                            Container(
                              height: 280, // Fixed height for the query list container
                              decoration: BoxDecoration(
                                color: AppColors.darkPurple,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Obx(() {
                                // Show loading indicator if queries are being fetched
                                if (queryController.isLoading && queryController.myQueries.isEmpty) {
                                  return Center(
                                    child: CircularProgressIndicator(color: AppColors.accentNeon),
                                  );
                                }
                                // Show message if no queries are found after loading
                                if (queryController.myQueries.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inbox_rounded, size: 70, color: AppColors.white.withOpacity(0.3)),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No queries raised yet.\nTap "Raise Query" to start one!',
                                            // Use bodyLarge with white color and custom height
                                            style: textTheme.bodyLarge?.copyWith(
                                              fontSize: 15, // Override if AppTheme's bodyLarge is not 15
                                              color: AppColors.white.withOpacity(0.7),
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                // Display queries if available
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: queryController.myQueries.length,
                                  itemBuilder: (context, index) {
                                    final query = queryController.myQueries[index];
                                    // Make sure query.replies is not null and check if it's empty
                                    // Also ensure `isAdmin` and `isRead` properties are handled correctly in QueryModel
                                    final bool hasUnreadAdminReply = query.replies != null && query.replies!.isNotEmpty &&
                                        query.replies!.last.isAdmin &&
                                        !(query.isRead ?? false); // Handle nullable isRead

                                    return InkWell(
                                      // Corrected: Add navigation after selecting the query
                                      onTap: () {
                                        queryController.selectQuery(query);
                                        // Navigate to QueryDetailScreen
                                        Get.to(() =>  QueryDetailScreen());
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        decoration: BoxDecoration(
                                          border: index == queryController.myQueries.length - 1
                                              ? null
                                              : Border(bottom: BorderSide(color: AppColors.white.withOpacity(0.1), width: 1)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: hasUnreadAdminReply ? AppColors.accentNeon.withOpacity(0.3) : AppColors.white.withOpacity(0.1),
                                              child: Icon(
                                                Icons.chat_bubble_outline,
                                                color: hasUnreadAdminReply ? AppColors.accentNeon : AppColors.white.withOpacity(0.8),
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 15.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    query.title,
                                                    // Use titleSmall and override properties
                                                    style: textTheme.titleSmall?.copyWith(
                                                      fontSize: 14, // Override if AppTheme's titleSmall is different
                                                      fontWeight: hasUnreadAdminReply ? FontWeight.w600 : FontWeight.w500,
                                                      color: AppColors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    query.message.length > 50
                                                        ? '${query.message.substring(0, 50)}...'
                                                        : query.message,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    // Use bodySmall and override color
                                                    style: textTheme.bodySmall?.copyWith(
                                                      fontSize: 11, // Override if AppTheme's bodySmall is different
                                                      color: AppColors.white.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10.0),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  DateFormat('MMM d').format(query.createdAt),
                                                  // Use labelSmall and override color/opacity
                                                  style: textTheme.labelSmall?.copyWith(
                                                    fontSize: 9, // Override if AppTheme's labelSmall is different
                                                    color: AppColors.white.withOpacity(0.5),
                                                  ),
                                                ),
                                                if (hasUnreadAdminReply)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 5),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.accentNeon,
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Text(
                                                        'NEW',
                                                        // Use labelSmall and override properties
                                                        style: textTheme.labelSmall?.copyWith(
                                                          fontSize: 8, // Override if AppTheme's labelSmall is different
                                                          color: AppColors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // Helper method to build action buttons
  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    // Get the TextTheme here as well
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 120,
          width: 140,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.darkPurple,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withOpacity(0.15), // Use AppColors for consistency
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.white, size: 30), // Use AppColors.white
              const SizedBox(height: 12),
              Text(
                label,
                // Use labelMedium and override color if necessary
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 13, // Override if AppTheme's labelMedium is different
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}