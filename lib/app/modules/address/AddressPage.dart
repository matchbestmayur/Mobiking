import 'package:flutter/material.dart';
import 'package:get/get.dart';
// If you uncommented GoogleFonts in previous files, keep it. Otherwise, remove if all text is themed.
// import 'package:google_fonts/google_fonts.dart';
import 'package:mobiking/app/themes/app_theme.dart'; // Import your AppTheme and AppColors

import '../../controllers/address_controller.dart';
import '../../data/AddressModel.dart';

class AddressPage extends StatelessWidget {
  AddressPage({Key? key}) : super(key: key) {
    // Only put the controller if it hasn't been put yet, to avoid re-creation
    // if the page is popped and pushed again.
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController());
    }
  }

  final AddressController controller = Get.find<AddressController>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme; // Get TextTheme

    return Scaffold(
      backgroundColor: AppColors.neutralBackground, // Consistent Blinkit-like background
      appBar: AppBar(
        leading: IconButton( // Use IconButton for standard back arrow styling
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back), // Standard back arrow
          color: AppColors.textDark, // Dark icon for clear visibility
        ),
        automaticallyImplyLeading: false, // Explicitly set
        title: Text(
          'Manage Addresses',
          style: textTheme.titleLarge?.copyWith( // Consistent AppBar title style
            color: AppColors.textDark, // Dark text
            fontWeight: FontWeight.w700, // Bold title
          ),
        ),
        backgroundColor: AppColors.white, // White AppBar background
        elevation: 0.5, // Subtle shadow for AppBar
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Center the FAB at the bottom
      floatingActionButton: Obx(() {
        if (!controller.isAddingAddress.value && !controller.isLoading.value) {
          // Changed to a full-width, bottom-docked button for adding address
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 54, // Consistent button height
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.isAddingAddress.value = true;
                },
                icon: const Icon(Icons.add, color: AppColors.white),
                label: Text(
                  'Add New Address',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, // Blinkit green for primary action
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for button
                  ),
                  elevation: 4, // Subtle shadow
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink(); // Hide FAB when form is open or loading
        }
      }),
      body: Obx(() {
        if (controller.isAddingAddress.value) {
          return _buildForm(context);
        } else if (controller.isLoading.value && controller.addresses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen), // Blinkit green loader
          );
        } else if (controller.addresses.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchAddresses();
            },
            color: AppColors.primaryGreen, // Refresh indicator in Blinkit green
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top -
                    80, // Adjust height to account for the FAB space at the bottom
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 60,
                        color: AppColors.textLight.withOpacity(0.6), // Subtle icon
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No addresses found.',
                        style: textTheme.headlineSmall?.copyWith(color: AppColors.textMedium), // Softer text
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add New Address" below to get started!', // Updated message
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return _buildAddressList(context);
        }
      }),
    );
  }

  Widget _buildAddressList(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchAddresses();
      },
      color: AppColors.primaryGreen, // Refresh indicator in Blinkit green
      child: ListView.separated(
        padding: const EdgeInsets.all(16), // Padding around the list
        itemCount: controller.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12), // Space between cards
        itemBuilder: (_, index) {
          final AddressModel addr = controller.addresses[index];
          final bool isSelected = controller.selectedAddress.value?.id == addr.id;

          return InkWell( // Use InkWell for better tap feedback on cards
            onTap: () {
              controller.selectAddress(addr);
              Get.back(); // Pop back to previous screen (e.g., Checkout)
            },
            borderRadius: BorderRadius.circular(12),
            child: Container( // Use Container instead of Card for precise decoration
              decoration: BoxDecoration(
                color: AppColors.white, // White background for the card
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppColors.primaryGreen, width: 2.0) // Green border if selected
                    : Border.all(color: AppColors.neutralBackground, width: 1.0), // Subtle border
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withOpacity(isSelected ? 0.1 : 0.05), // Slightly more shadow if selected
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getEmojiForLabel(addr.label)} ${addr.label}',
                        style: textTheme.titleMedium?.copyWith( // Consistent title for label
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark, // Dark text
                        ),
                      ),
                      const SizedBox(height: 8), // Adjusted spacing
                      Text(
                        addr.street,
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textMedium, height: 1.4), // BodyLarge for street
                      ),
                      Text(
                        '${addr.city}, ${addr.state} - ${addr.pinCode}',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textMedium, height: 1.4), // BodyLarge for city/state/pin
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: 0, // Align with top of content
                      right: 0, // Align with right of content
                      child: Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 28), // Green checkmark
                    ),
                  // Option to Edit/Delete - common in Blinkit (though not explicitly requested, good UX)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      children: [
                        // Edit Button (Optional: Implement edit functionality)
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.textLight, size: 20),
                          onPressed: () {
                            // controller.editAddress(addr); // Call your edit method
                            Get.snackbar('Edit Address', 'Implement address edit functionality.', snackPosition: SnackPosition.BOTTOM);
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button (Optional: Implement delete functionality)
                        IconButton(
                          icon: Icon(Icons.delete, color: AppColors.danger, size: 20),
                          onPressed: () {
                            // controller.deleteAddress(addr.id); // Call your delete method
                            Get.snackbar('Delete Address', 'Implement address delete functionality.', snackPosition: SnackPosition.BOTTOM);
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEmojiForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return '🏠';
      case 'work':
      case 'office':
        return '🏢';
      default:
        return '📍';
    }
  }

  Widget _buildForm(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              context: context,
              label: "Street Address, House No.",
              controller: controller.streetController,
              validator: (val) => val == null || val.trim().isEmpty ? 'Street address is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: "City",
              controller: controller.cityController,
              validator: (val) => val == null || val.trim().isEmpty ? 'City is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: "State / Province",
              controller: controller.stateController,
              validator: (val) => val == null || val.trim().isEmpty ? 'State is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: "PIN Code / Postal Code",
              keyboardType: TextInputType.number,
              controller: controller.pinCodeController,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'PIN code is required';
                if (!RegExp(r'^\d{4,10}$').hasMatch(val.trim())) return 'Invalid PIN code (4-10 digits)'; // More precise message
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align "Address Type" label to start
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Address Type',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute evenly
                    children: ['Home', 'Work', 'Other'].map((label) {
                      final isSelected = controller.selectedLabel.value == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) controller.selectedLabel.value = label;
                        },
                        labelStyle: textTheme.labelMedium?.copyWith(
                            color: isSelected ? AppColors.white : AppColors.textDark, // Dark text when not selected
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500), // Bolder when selected
                        backgroundColor: AppColors.neutralBackground, // Light grey for unselected
                        selectedColor: AppColors.primaryGreen, // Blinkit green for selected
                        shape: RoundedRectangleBorder( // Rounded rectangle shape
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryGreen : AppColors.textLight.withOpacity(0.5), // Themed border
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        elevation: 0, // No elevation for chips
                        pressElevation: 0, // No press elevation
                      );
                    }).toList(),
                  ),
                  if (controller.selectedLabel.value == 'Other') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      context: context,
                      label: 'Custom Label (e.g., "Friend\'s House")',
                      controller: controller.customLabelController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'A custom label is required' : null,
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54, // Consistent button height
              child: Obx(() => ElevatedButton.icon(
                icon: controller.isLoading.value
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save, color: AppColors.white), // Standard save icon
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await controller.addAddress();
                    if (success) {
                      Get.snackbar(
                        'Success',
                        'Address saved successfully!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.success,
                        colorText: AppColors.white,
                        margin: const EdgeInsets.all(10), // Consistent margin
                        borderRadius: 10,
                      );
                      controller.isAddingAddress.value = false;
                      controller.clearForm();
                      // Refresh list after adding
                      controller.fetchAddresses();
                    } else {
                      Get.snackbar(
                        'Error',
                        'Failed to save address. Please try again.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.danger,
                        colorText: AppColors.white,
                        margin: const EdgeInsets.all(10), // Consistent margin
                        borderRadius: 10,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, // Blinkit green for save
                  disabledBackgroundColor: AppColors.lightGreen.withOpacity(0.5), // Lighter disabled color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4, // Subtle shadow
                ),
                label: Text(
                  controller.isLoading.value ? "Saving..." : "Save Address",
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700, // Bolder text
                  ),
                ),
              )),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                controller.isAddingAddress.value = false;
                controller.clearForm();
              },
              child: Text(
                'Cancel',
                style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textMedium, fontWeight: FontWeight.w600), // Medium grey for cancel
              ),
            ),
            const SizedBox(height: 20), // Bottom padding for scroll view
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: textTheme.bodyLarge?.copyWith(color: AppColors.textDark), // Input text style
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium, // Label color
        ),
        filled: true,
        fillColor: AppColors.white, // White fill for text field
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder( // Default border
          borderSide: BorderSide(color: AppColors.neutralBackground), // Subtle grey border
          borderRadius: BorderRadius.circular(8), // Slightly less rounded for text fields
        ),
        enabledBorder: OutlineInputBorder( // Enabled state border
          borderSide: BorderSide(color: AppColors.neutralBackground),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder( // Focused state border
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2), // Green focus border
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder( // Error state border
          borderSide: BorderSide(color: AppColors.danger, width: 1.5), // Red error border
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder( // Focused error state border
          borderSide: BorderSide(color: AppColors.danger, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}