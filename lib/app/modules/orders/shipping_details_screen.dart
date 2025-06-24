// Path: lib/app/modules/order_history/shipping_details_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting in details

import '../../themes/app_theme.dart'; // Ensure this path is correct

// Only import MilestoneTimeline and its Milestone model
import 'package:animated_milestone/view/milestone_timeline.dart';
import 'package:animated_milestone/model/milestone.dart' as am_milestone; // Alias for clarity


class ShippingDetailsScreen extends StatelessWidget {
  const ShippingDetailsScreen({Key? key}) : super(key: key);

  static final DateTime now = DateTime.now();
  static final Map<String, dynamic> dummyTrackingData = {
  "scans": [
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 3, hours: 10, minutes: 30))),
  "status": "ORDER_PLACED",
  "activity": "Order Confirmed - Your order has been placed successfully.",
  "location": "Online Store",
  "sr-status": "10",
  "sr-status-label": "ORDER PLACED"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 3, hours: 8, minutes: 15))),
  "status": "MANIFESTED",
  "activity": "Manifested - Package details updated for shipment.",
  "location": "Warehouse, Delhi (India)",
  "sr-status": "5",
  "sr-status-label": "MANIFEST GENERATED"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 3, hours: 6, minutes: 45))),
  "status": "PICKED_UP",
  "activity": "In Transit - Shipment picked up from sender.",
  "location": "Warehouse, Delhi (India)",
  "sr-status": "42",
  "sr-status-label": "PICKED UP"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 2, hours: 23, minutes: 0))),
  "status": "IN_TRANSIT_ORIGIN_SORT",
  "activity": "In Transit - Arrived at origin sorting facility.",
  "location": "Delhi Sorting Center (India)",
  "sr-status": "6",
  "sr-status-label": "SHIPPED"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 2, hours: 18, minutes: 0))),
  "status": "DEPARTED_ORIGIN_SORT",
  "activity": "In Transit - Departed origin sorting facility.",
  "location": "Delhi Sorting Center (India)",
  "sr-status": "18",
  "sr-status-label": "IN TRANSIT"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 1, hours: 15, minutes: 0))),
  "status": "IN_TRANSIT_HUB",
  "activity": "In Transit - Arrived at transit hub.",
  "location": "Mumbai Transit Hub (Maharashtra)",
  "sr-status": "18",
  "sr-status-label": "IN TRANSIT"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(days: 1, hours: 8, minutes: 0))),
  "status": "DEPARTED_HUB",
  "activity": "In Transit - Departed transit hub.",
  "location": "Mumbai Transit Hub (Maharashtra)",
  "sr-status": "18",
  "sr-status-label": "IN TRANSIT"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(hours: 20, minutes: 0))),
  "status": "IN_TRANSIT_DEST_SORT",
  "activity": "In Transit - Arrived at destination sorting facility.",
  "location": "Jhabua Sorting Center (Madhya Pradesh)",
  "sr-status": "18",
  "sr-status-label": "IN TRANSIT"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(hours: 4, minutes: 30))),
  "status": "OUT_FOR_DELIVERY",
  "activity": "Out for Delivery - Package handed over to local courier for delivery.",
  "location": "Jhabua Local Delivery (Madhya Pradesh)",
  "sr-status": "21",
  "sr-status-label": "OUT FOR DELIVERY"
  },
  {
  "date": DateFormat("yyyy-MM-dd HH:mm:ss").format(now.subtract(const Duration(minutes: 5))), // Very recent
  "status": "DELIVERED",
  "activity": "Delivered - Package successfully delivered to recipient.",
  "location": "Jhabua, Madhya Pradesh (India)",
  "sr-status": "3",
  "sr-status-label": "DELIVERED"
  }
  ],
  "is_return": 0,
  "channel_id": 3422553,
  "pod_status": "Delivered - Signed by Customer", // More realistic for a delivered status
  "pod": "Available" // Now it's available
  };
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Determine the current tracking status for display
    String currentActivity = dummyTrackingData['scans'].last['activity'];
    String currentLocation = dummyTrackingData['scans'].last['location'];
    String currentStatusLabel = dummyTrackingData['scans'].last['sr-status-label'];

    // Map your tracking statuses to the Amazon-like milestones for the overall progress
    final List<String> overallMilestones = [
      'Order Placed',
      'Shipped',
      'In Transit',
      'Out for Delivery', // You'll need specific status for this
      'Delivered', // You'll need specific status for this
    ];

    // Determine which overall milestone is active based on the latest scan
    int currentOverallMilestoneIndex = 0;
    if (currentStatusLabel.contains('MANIFEST GENERATED') || currentStatusLabel.contains('PICKED UP')) {
      currentOverallMilestoneIndex = 0; // Order Placed
    } else if (currentStatusLabel.contains('SHIPPED') || currentActivity.contains('Origin Center')) {
      currentOverallMilestoneIndex = 1; // Shipped
    } else if (currentStatusLabel.contains('IN TRANSIT') || currentActivity.contains('Trip Arrived') || currentActivity.contains('Received at Facility') || currentActivity.contains('Added to Bag')) {
      currentOverallMilestoneIndex = 2; // In Transit
    }
    // Add specific conditions for 'Out for Delivery' and 'Delivered'
    // For now, it will likely stop at 'In Transit' given the dummy data.


    // Prepare data for MilestoneTimeline (combining overall and detailed views)
    // We'll create milestones for the overall progress, and then append the detailed scans.

    List<am_milestone.Milestone> combinedMilestones = [];

    // 1. Add overall progress milestones first
    for (int i = 0; i < overallMilestones.length; i++) {
      String milestoneTitle = overallMilestones[i];
      bool isActive = i <= currentOverallMilestoneIndex; // Highlight up to the current overall status

      combinedMilestones.add(
        am_milestone.Milestone(
          isActive: isActive,
          title: Text(
            milestoneTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.textDark : AppColors.textLight, // Darker for active, lighter for inactive
            ),
          ),
          child: i == currentOverallMilestoneIndex // Add a description only for the current active milestone
              ? Text(
            'Your package is $currentActivity at $currentLocation.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMedium),
          )
              : const SizedBox.shrink(), // No description for inactive overall milestones
          // You could also add an icon for completed states here:
          // icon: i < currentOverallMilestoneIndex ? Icon(Icons.check_circle_rounded, color: AppColors.success) : null,
        ),
      );
      // If this is the current active overall milestone, we might want to break here
      // or add a separator before the detailed history starts.
      if (i == currentOverallMilestoneIndex && dummyTrackingData['scans'].isNotEmpty) {
        combinedMilestones.add(
          am_milestone.Milestone( // Adding a "spacer" or "start of details" milestone
            isActive: true, // Always active as it's the start of the detailed log
            title: Text(
              'Detailed History:',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            child: const SizedBox.shrink(), // No content for this separator
          ),
        );
      }
    }


    // 2. Append detailed scan history (reversed to show newest first)
    final List<Map<String, dynamic>> reversedScans = dummyTrackingData['scans'].reversed.toList().cast<Map<String, dynamic>>();

    for (int i = 0; i < reversedScans.length; i++) {
      final scan = reversedScans[i];
      final String date = scan['date'];
      final String activity = scan['activity'];
      final String location = scan['location'];

      DateTime scanDateTime = DateTime.parse(date);
      String formattedDate = DateFormat('dd MMM, hh:mm a').format(scanDateTime.toLocal());

      bool isLastScan = (i == 0); // The first item in reversed list is the latest scan

      combinedMilestones.add(
        am_milestone.Milestone(
          isActive: isLastScan, // Highlight only the very latest detailed scan
          icon: isLastScan ? const Icon(Icons.location_on, color: AppColors.success, size: 20) : null, // Custom icon for latest
          title: Text(
            activity,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis, // Applied here
              color: AppColors.textDark,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
              ),
              Text(
                location,
                style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textMedium,
                    overflow: TextOverflow.ellipsis // Applied here
                ),
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      appBar: AppBar(
        title: Text(
          'Shipment Tracking',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0.5,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Card with Current Status (simplified as overall milestones will be in timeline)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overallMilestones[currentOverallMilestoneIndex], // Display current overall milestone
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.success, // Highlight current status in success color
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your package is $currentActivity at $currentLocation.',
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expected delivery: Monday, June 8, 2025 (Updated 0 minute(s) ago)', // Dummy date
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Spacing below the current status card

            // Combined Overall Progress and Detailed Tracking Timeline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: MilestoneTimeline(
                milestones: combinedMilestones,
                color: AppColors.success, // Color for active elements
                circleRadius: 8, // Adjust circle size for main milestones
                stickThickness: 2, // Thinner stick
                activeWithStick: true, // Connect active milestones with the stick
                showLastStick: true, // Show stick for the last milestone
                greyoutContentWithInactive: false, // Don't grey out content of inactive milestones
                milestoneIntervalDurationInMillis: 300, // Speed of animation between milestones
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}