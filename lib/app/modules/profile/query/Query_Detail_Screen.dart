// lib/screens/query_detail_screen.dart
import 'dart:ui'; // Required for ImageFilter and BackdropFilter

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/Query_Controller.dart';
import '../../../data/QueryModel.dart'; // Ensure QueryModel.dart has ReplyModel if it's separate
import '../../../themes/app_theme.dart'; // Import AppColors and other theme elements
// import 'Raise_query.dart'; // This import is not used in this specific screen, can be removed if not needed for the project build

class QueryDetailScreen extends StatelessWidget {
  final QueryController queryController = Get.find<QueryController>();
  final TextEditingController _replyController = TextEditingController();

  QueryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the selected query from the controller
    final QueryModel? query = queryController.selectedQuery.value;

    // Handle case where query is null (e.g., direct navigation without selecting a query)
    if (query == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Query not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Light background for the overall screen
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Clear selected query in controller when leaving the detail screen
            queryController.clearSelectedQuery();
            Get.back(); // Navigate back to the previous screen
          },
        ),
        title: Text(
          'Query Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600, // Slightly bolder title
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkPurple, // Dark purple AppBar background
        elevation: 0, // No shadow for a flat, modern app bar
      ),
      body: Column( // This is the main column for the screen content
        children: [
          // Query Title and Message Card (Now with Glassmorphic background)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Consistent horizontal margin
            child: ClipRRect( // Crucial for clipping the blur to the rounded corners
              borderRadius: BorderRadius.circular(15), // Match the Container's border radius
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply the blur effect (adjust sigmaX/Y for intensity)
                child: Container(
                  decoration: BoxDecoration(
                    // Translucent purple color for the glass effect
                    color: AppColors.primaryPurple.withOpacity(0.1), // Using a light translucent purple
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    // Subtle border to define the glass element
                    border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                  ),
                  padding: const EdgeInsets.all(20.0), // Padding inside the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark, // Dark text on translucent background
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        query.message,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textDark.withOpacity(0.7), // Muted dark text for message content
                        ),
                      ),
                      const SizedBox(height: 12.0), // Increased spacing
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          'Opened: ${DateFormat('MMM d, hh:mm a').format(query.createdAt)}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textDark.withOpacity(0.5), // More muted for timestamp
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 10.0), // Consistent horizontal padding for "Replies" title
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Replies',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          // Replies Section Container (Now with Glassmorphic background)
          Expanded( // Allows the replies section to take available vertical space
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0), // Consistent horizontal margin
              child: ClipRRect( // Crucial for clipping the blur to the rounded corners
                borderRadius: BorderRadius.circular(15), // Match the Container's border radius
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Apply the blur effect
                  child: Container(
                    padding: const EdgeInsets.all(16.0), // Padding inside the replies section
                    decoration: BoxDecoration(
                      // Translucent purple color for the glass effect background of the entire section
                      color: AppColors.primaryPurple.withOpacity(0.1), // Adjusted opacity
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      // Subtle border to define the glass element
                      border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3), width: 1.0),
                    ),
                    child: StreamBuilder<List<ReplyModel>>( // Use StreamBuilder to react to new replies
                      stream: queryController.replyStream,
                      initialData: query.replies, // Initial data from the query object
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(color: AppColors.accentNeon)); // Loading indicator
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: AppColors.danger)));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No replies yet. Start the conversation!',
                              style: GoogleFonts.poppins(color: AppColors.textDark.withOpacity(0.6)), // Muted text for no replies
                            ),
                          );
                        }

                        final replies = snapshot.data!;
                        return ListView.builder(
                          reverse: true, // Shows latest messages at the bottom, auto-scrolls
                          itemCount: replies.length,
                          itemBuilder: (context, index) {
                            // Display replies in chronological order, but list builds from bottom up due to `reverse: true`
                            final reply = replies[replies.length - 1 - index];
                            final isUser = !reply.isAdmin; // Determine if the message is from the user or admin

                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, // Align based on sender
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(14),
                                constraints: BoxConstraints(maxWidth: Get.width * 0.75), // Limit bubble width
                                decoration: BoxDecoration(
                                  // Message bubbles remain solid for clear readability against the blurred background
                                  color: isUser ? AppColors.primaryPurple : Colors.white, // User's message: Primary Purple, Admin's: White
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(15),
                                    topRight: const Radius.circular(15),
                                    bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(5), // Tail for user bubble
                                    bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(15), // Tail for admin bubble
                                  ),
                                  boxShadow: [ // Subtle shadow for message bubbles
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
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
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: isUser ? Colors.white : AppColors.textDark, // Text color contrasts with bubble background
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateFormat('hh:mm a').format(reply.timestamp), // Format timestamp
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: isUser ? Colors.white.withOpacity(0.7) : AppColors.textLight.withOpacity(0.8), // Muted timestamp
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Message text field with attachment option (Input area remains solid for usability)
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0), // More generous and consistent padding
            child: Row(
              children: [
                // Attachment Icon
                Container(
                  margin: const EdgeInsets.only(right: 10.0), // Spacing from text field
                  decoration: BoxDecoration(
                    color: AppColors.darkPurple, // Dark purple background for attachment button
                    borderRadius: BorderRadius.circular(30), // Circular button
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.attach_file_rounded, // Attachment icon
                      color: Colors.white.withOpacity(0.9), // White icon
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Implement logic to open image/video picker
                      Get.snackbar(
                        'Attachment',
                        'Feature to add photo/video will be implemented here!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primaryPurple,
                        colorText: Colors.white,
                      );
                    },
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textLight.withOpacity(0.7)),
                      border: OutlineInputBorder( // Defined border for clearer separation
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none, // Initially no border for a cleaner look
                      ),
                      enabledBorder: OutlineInputBorder( // Border when enabled (not focused)
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: AppColors.primaryPurple.withOpacity(0.4), width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder( // Border when focused
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0), // Stronger border when focused
                      ),
                      filled: true,
                      fillColor: Colors.white, // White fill color for input background
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      // Add a suffix icon for emojis, maybe? (Optional)
                      // suffixIcon: Icon(Icons.mood, color: AppColors.textLight),
                    ),
                    style: GoogleFonts.poppins(color: AppColors.textDark), // Dark input text
                    maxLines: null, // Allows multiline input
                    keyboardType: TextInputType.multiline, // Soft keyboard type for multiple lines
                    cursorColor: AppColors.primaryPurple, // Themed cursor
                  ),
                ),
                const SizedBox(width: 10.0), // Spacing between text field and send button
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.accentNeon, // Bright accent for send button
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_replyController.text.trim().isNotEmpty) {
                        // Add reply using the controller
                        queryController.addReply(_replyController.text.trim());
                        _replyController.clear(); // Clear text field after sending
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}