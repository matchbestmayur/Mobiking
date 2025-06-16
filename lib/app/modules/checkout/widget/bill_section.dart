import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillSection extends StatelessWidget {
  final int itemTotal;
  final int deliveryCharge;
  final int gstCharge;

  const BillSection({
    Key? key,
    required this.itemTotal,
    required this.deliveryCharge,
    required this.gstCharge,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final total = itemTotal + deliveryCharge + gstCharge;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 Billing Heading
          Text(
            "Billing Details",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Divider(color: Colors.grey.shade300, thickness: 1),

          _billRow("Items total", itemTotal),
          _billRow("Delivery charge", deliveryCharge),
          _billRow("GST (18%)", gstCharge),

          Divider(color: Colors.grey.shade300, thickness: 1),

          _billRow("Grand total", total, isBold: true),
        ],
      ),
    );
  }


  Widget _billRow(String label, int value, {bool isBold = false}) {
    final textStyle = GoogleFonts.poppins(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      fontSize: isBold ? 16 : 14,
      color: Colors.black87,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text("₹$value", style: textStyle),
        ],
      ),
    );
  }
}
