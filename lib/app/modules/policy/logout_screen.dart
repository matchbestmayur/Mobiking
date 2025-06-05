import 'package:flutter/material.dart';
import 'package:mobiking/app/themes/app_theme.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor:  AppColors.neutralBackground, // Neutral background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: const [
          Icon(Icons.logout, color: Colors.deepPurple),
          SizedBox(width: 8),
          Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to logout from your account?',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.cancel, color: Colors.grey),
          label: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            // Add your logout logic here
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Logout',),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.darkPurple,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}
