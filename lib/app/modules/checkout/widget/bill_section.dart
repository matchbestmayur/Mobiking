import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart'; // Import your AppTheme and AppColors

class BillSection extends StatelessWidget {
  final int itemTotal;
  final int deliveryCharge;
  // If gstCharge needs to be re-introduced later, uncomment and re-integrate.
  // final int gstCharge;

  const BillSection({
    Key? key,
    required this.itemTotal,
    required this.deliveryCharge,
    // required this.gstCharge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the TextTheme from the current theme for consistent typography
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Calculate total, ensuring all charges are included if active
    final int total = itemTotal + deliveryCharge;
    // if (gstCharge != null) total += gstCharge; // Uncomment if gstCharge is active

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 12), // Parent already handles spacing
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white, // Use white for the card background, not neutralBackground
        borderRadius: BorderRadius.circular(12), // Consistent rounded corners
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.05), // Subtle shadow for elevation
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 Billing Heading (Blinkit often uses a subtle, smaller title for this section)
          Text(
            "Bill Details", // Renamed for common usage
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16, // Consistent with previous uses for sub-headings
              fontWeight: FontWeight.w700, // Bold for emphasis
              color: AppColors.textDark, // Dark text for readability
            ),
          ),
          const SizedBox(height: 12), // Spacing after heading

          // Subtle divider line
          Divider(color: AppColors.neutralBackground, thickness: 1), // Very light divider
          const SizedBox(height: 4), // Small space after divider

          _buildBillRow("Items total", itemTotal, textTheme),
          _buildBillRow("Delivery charge", deliveryCharge, textTheme),
          // If you re-introduce GST, uncomment this line:
          // _buildBillRow("GST (18%)", gstCharge, textTheme),

          const SizedBox(height: 4), // Small space before total divider
          // More prominent divider before the grand total
          Divider(color: AppColors.textMedium.withOpacity(0.5), thickness: 1.5),
          const SizedBox(height: 4), // Small space after total divider

          _buildBillRow("Grand total", total, textTheme, isBold: true),
        ],
      ),
    );
  }

  // Helper method for a single bill row
  Widget _buildBillRow(String label, int value, TextTheme textTheme, {bool isBold = false}) {
    // Style for the label (e.g., "Items total")
    final TextStyle labelStyle = textTheme.bodyLarge?.copyWith(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, // Bold for total, medium for others
      color: isBold ? AppColors.textDark : AppColors.textMedium, // Dark for total, medium for others
      fontSize: isBold ? 16 : 14, // Slightly larger for total
    ) ?? const TextStyle(); // Provide a default if null

    // Style for the value (e.g., "₹120")
    final TextStyle valueStyle = textTheme.bodyLarge?.copyWith(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: isBold ? AppColors.textDark : AppColors.textMedium,
      fontSize: isBold ? 16 : 14,
    ) ?? const TextStyle();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Adjusted vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelStyle),
          Text("₹$value", style: valueStyle),
        ],
      ),
    );
  }
}