// lib/screens/queries_screen.dart
import 'dart:ui'; // Make sure this is imported

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/Query_Controller.dart';
import '../../../data/QueryModel.dart';
import '../../../themes/app_theme.dart';
import 'AboutUsDialog.dart';
import 'FaqDialog.dart';
import 'Raise_query.dart'; // Your custom dialog


class QueriesScreen extends StatefulWidget {
  const QueriesScreen({super.key});

  @override
  State<QueriesScreen> createState() => _QueriesScreenState();
}

class _QueriesScreenState extends State<QueriesScreen> {
  final QueryController queryController = Get.put(QueryController());
  // IMPORTANT: Declare the TextEditingController here to persist its state
  final TextEditingController _queryInputController = TextEditingController();

  @override
  void dispose() {
    _queryInputController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Light background for the overall screen
      body: CustomScrollView(
        slivers: [
          // Top Section: 'Talk with Support' and Quick Input
          SliverAppBar(
            expandedHeight: 220.0, // Slightly increased height for more breathing room
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
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 90.0, 24.0, 0), // Consistent horizontal padding, adjusted top
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talk with Support',
                        style: GoogleFonts.poppins(
                          fontSize: 30, // Slightly larger title
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 20), // Increased space below title
                      // Prompt/Input Field
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), // More vertical padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32), // More rounded
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20, // Softer, wider blur
                              offset: const Offset(0, 10), // Deeper shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _queryInputController, // Use the shared controller
                                decoration: InputDecoration(
                                  hintText: 'Ask a quick question...',
                                  hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 16), // Slightly larger input text
                                cursorColor: AppColors.primaryPurple,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Icon(Icons.mic, color: AppColors.textLight.withOpacity(0.8)), // Slightly darker mic
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                // Handle sending the quick question
                                if (_queryInputController.text.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Quick question sent: "${_queryInputController.text}"')),
                                  );
                                  _queryInputController.clear();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12), // Larger send button
                                decoration: BoxDecoration(
                                  color: AppColors.accentNeon,
                                  borderRadius: BorderRadius.circular(28), // Fully rounded
                                ),
                                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
            padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 0), // Adjust top padding to create gap from header
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // START Glassmorphic effect for Quick Actions
                  ClipRRect( // Crucial for clipping the blur to rounded corners
                    borderRadius: const BorderRadius.all(Radius.circular(18)), // Match Container's border radius
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur
                      child: Container(
                        decoration: BoxDecoration(
                          // Use a translucent color from your theme for the glass effect
                          color: AppColors.primaryPurple.withOpacity(0.1), // Using a translucent purple
                          borderRadius: const BorderRadius.all(Radius.circular(18)), // Rounded corners for the card
                          // Subtle border using a slightly more opaque version of the same color
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                        ),
                        // Consistent horizontal padding for quick actions content
                        padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: GoogleFonts.poppins(
                                fontSize: 20, // Slightly larger section title
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark, // Remains dark for readability on light glass
                              ),
                            ),
                            const SizedBox(height: 22), // More space below title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(
                                  context,
                                  icon: Icons.message_outlined,
                                  label: 'Raise Query',
                                  onTap: () {
                                    Get.dialog(
                                      RaiseQueryDialog(
                                        onAddQuery: (title, message) {
                                          queryController.addNewQuery(title, message, 'xyz2011@gmail.com');
                                        },
                                      ),
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  context,
                                  icon: Icons.lightbulb_outline,
                                  label: 'View \n FAQs',
                                  onTap: () {
                                    // NEW: Show the FAQ dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return FaqDialog(queryController: _queryInputController);
                                      },
                                    );
                                  },
                                ),
                                _buildActionButton(
                                  context,
                                  icon: Icons.contact_support_outlined,
                                  label: 'About \n Us', // Changed label for clarity, as requested
                                  onTap: () {
                                    // NEW: Show the About Us dialog
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
                  // END Glassmorphic effect for Quick Actions
                ],
              ),
            ),
          ),

          // Previous Queries Section (Now with contrasting Glassmorphic effect)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 25.0), // Consistent horizontal, vertical space from above
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // START Glassmorphic effect for Previous Queries Outer Container
                  ClipRRect( // Clip content to rounded corners for blur effect
                    borderRadius: BorderRadius.circular(20), // Match Container's border radius
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply blur
                      child: Container( // Outer container for the entire elevated section
                        decoration: BoxDecoration(
                          // Use a translucent color from your theme for the glass effect
                          color: AppColors.primaryPurple.withOpacity(0.1), // Using a translucent purple
                          borderRadius: BorderRadius.circular(20), // Rounded corners for the entire card
                          // Subtle border using a slightly more opaque version of the same color
                          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                        ),
                        padding: const EdgeInsets.all(20.0), // Internal padding for the card
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Previous Queries',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20, // Consistent section title size
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark, // Still dark text for readability on light glass
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18), // Spacing below title
                            // The inner Container with the actual scrollable list (dark background)
                            // This part should NOT be blurred. Its background should remain solid.
                            Container(
                              height: 280, // Fixed height for scrollable window
                              decoration: BoxDecoration(
                                color: AppColors.darkPurple, // Dark background for the queries list
                                borderRadius: BorderRadius.circular(15), // Rounded corners for the inner list container
                              ),
                              child: Obx(() {
                                if (queryController.queries.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inbox_rounded, size: 70, color: Colors.white.withOpacity(0.3)),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No queries raised yet.\nTap "Raise Query" to start one!',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              color: Colors.white.withOpacity(0.7),
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: queryController.queries.length,
                                  itemBuilder: (context, index) {
                                    final query = queryController.queries[index];
                                    final bool hasUnreadAdminReply = query.replies.isNotEmpty &&
                                        query.replies.last.isAdmin &&
                                        !query.isRead;

                                    return InkWell(
                                      onTap: () => queryController.selectQuery(query),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        decoration: BoxDecoration(
                                          border: index == queryController.queries.length - 1
                                              ? null
                                              : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: hasUnreadAdminReply ? AppColors.accentNeon.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                                              child: Icon(
                                                Icons.chat_bubble_outline,
                                                color: hasUnreadAdminReply ? AppColors.accentNeon : Colors.white.withOpacity(0.8),
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
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: hasUnreadAdminReply ? FontWeight.w600 : FontWeight.w500,
                                                      color: Colors.white,
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
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: Colors.white.withOpacity(0.7),
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
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9,
                                                    color: Colors.white.withOpacity(0.5),
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
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 8,
                                                          color: Colors.white,
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
                  // END Glassmorphic effect for Previous Queries Outer Container
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 30)), // Bottom padding for CustomScrollView
        ],
      ),
    );
  }

  // Helper method to build action buttons
  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18), // Match button border radius for consistent tap effect
        child: Container(
          height: 120,
          width: 140,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 20), // Uniform vertical padding for all buttons
          decoration: BoxDecoration(
            color: AppColors.darkPurple, // Dark purple background for buttons
            borderRadius: BorderRadius.circular(18), // Slightly more rounded buttons
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Stronger, more defined shadow for buttons
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 12), // More space between icon and text
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
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
