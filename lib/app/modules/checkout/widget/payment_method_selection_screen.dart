// lib/app/modules/checkout/views/payment_method_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/themes/app_theme.dart';
import '../../../controllers/order_controller.dart'; // Assuming you have an OrderController

class PaymentMethodSelectionScreen extends StatelessWidget {
  final RxString selectedPaymentMethod;
  final OrderController orderController; // Pass the OrderController

  PaymentMethodSelectionScreen({
    Key? key,
    required this.selectedPaymentMethod,
    required this.orderController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      appBar: AppBar(
        title: Text(
          "Select Payment Method",
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Wrap _buildPaymentOption with Obx to react to changes
              Obx(() { // <--- Added Obx here
                return _buildPaymentOption(
                  context: context,
                  title: "Cash on Delivery (COD)",
                  description: "Pay with cash upon delivery.",
                  icon: Icons.money_rounded,
                  onTap: orderController.isLoading.value
                      ? null
                      : () {
                    selectedPaymentMethod.value = 'COD';
                  },
                  isLoading: orderController.isLoading.value && selectedPaymentMethod.value == 'COD',
                  isSelected: selectedPaymentMethod.value == 'COD',
                );
              }),
              const SizedBox(height: 12),
              // Wrap _buildPaymentOption with Obx to react to changes
              Obx(() { // <--- Added Obx here
                return _buildPaymentOption(
                  context: context,
                  title: "Online Payment",
                  description: "Pay securely online with cards or UPI.",
                  icon: Icons.payment_rounded,
                  onTap: orderController.isLoading.value
                      ? null
                      : () {
                    selectedPaymentMethod.value = 'Online';
                  },
                  isLoading: orderController.isLoading.value && selectedPaymentMethod.value == 'Online',
                  isSelected: selectedPaymentMethod.value == 'Online',
                );
              }),
              const Spacer(), // Pushes buttons to the bottom
              Obx(() => Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Just navigate back, don't set method
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger.withOpacity(0.1),
                        foregroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0,
                        // The border color here had AppColors.danger, but subtle is better like the other elements
                        side: const BorderSide(color: AppColors.danger, width: 1), // Changed to be consistent
                      ),
                      child: Text(
                        'Cancel',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (selectedPaymentMethod.value.isEmpty || orderController.isLoading.value)
                          ? null
                          : () async {
                        // Pass the selected method back to the previous screen
                        Get.back(result: selectedPaymentMethod.value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                        elevation: 4,
                        disabledBackgroundColor: AppColors.lightPurple.withOpacity(0.5),
                      ),
                      child: orderController.isLoading.value
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 3),
                      )
                          : Text(
                        'Select',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for payment options
  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback? onTap,
    required bool isSelected,
    required bool isLoading,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1.0, // Dim if loading
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightPurple.withOpacity(0.2) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryPurple : AppColors.lightPurple,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              BoxShadow(
                color: AppColors.textDark.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryPurple : AppColors.textMedium, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primaryPurple : AppColors.textDark,
                      ),
                    ),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
              // No need for isLoading here, as the Opacity and onTap handle it.
              // If you want a loader inside the tile, you can add it,
              // but the primary loading state is handled by the buttons.
            ],
          ),
        ),
      ),
    );
  }
}