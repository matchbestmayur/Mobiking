import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobiking/app/themes/app_theme.dart';

import '../../controllers/address_controller.dart';
import '../../data/AddressModel.dart';

class AddressPage extends StatelessWidget {
  AddressPage({Key? key}) : super(key: key) {
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController());
    }
  }

  final AddressController controller = Get.find<AddressController>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textDark,
        ),
        automaticallyImplyLeading: false,
        title: Obx(() => Text( // Title changes based on form state
          controller.isEditingMode ? 'Edit Address' : 'Manage Addresses',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        )),
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        if (!controller.isFormOpen && !controller.isLoading.value) { // Show FAB only when form is NOT open and not loading
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.startAddingAddress(); // Call the new method to start adding
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
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: Obx(() {
        if (controller.isFormOpen) { // Check if any form (add or edit) is open
          return _buildForm(context);
        } else if (controller.isLoading.value && controller.addresses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        } else if (controller.addresses.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchAddresses();
            },
            color: AppColors.primaryGreen,
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
                        color: AppColors.textLight.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No addresses found.',
                        style: textTheme.headlineSmall?.copyWith(color: AppColors.textMedium),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add New Address" below to get started!',
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

    // Calculate bottom padding based on FAB height + its vertical padding (8.0 * 2)
    const double fabTotalHeight = 54.0 + (8.0 * 2);
    const double extraBottomPadding = 20.0;
    const double totalBottomPadding = fabTotalHeight + extraBottomPadding;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchAddresses();
      },
      color: AppColors.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, totalBottomPadding),
        itemCount: controller.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final AddressModel addr = controller.addresses[index];
          final bool isSelected = controller.selectedAddress.value?.id == addr.id;

          return InkWell(
            onTap: () {
              controller.selectAddress(addr);
              Get.back();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: AppColors.primaryGreen, width: 2.0)
                    : Border.all(color: AppColors.neutralBackground, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withOpacity(isSelected ? 0.1 : 0.05),
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
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        addr.street,
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textMedium, height: 1.4),
                      ),
                      Text(
                        '${addr.city}, ${addr.state} - ${addr.pinCode}',
                        style: textTheme.bodyLarge?.copyWith(color: AppColors.textMedium, height: 1.4),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 28),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Row(
                      children: [
                        // Edit Button: Calls controller.startEditingAddress
                        IconButton(
                          icon: Icon(Icons.edit, color: AppColors.textLight, size: 20),
                          onPressed: () {
                            controller.startEditingAddress(addr); // Call the new method
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: AppColors.danger, size: 20),
                          onPressed: () async {
                            if (addr.id != null) {
                              final bool confirmed = await Get.dialog<bool>(
                                AlertDialog(
                                  title: Text('Delete Address', style: textTheme.titleLarge),
                                  content: Text('Are you sure you want to delete this address?', style: textTheme.bodyMedium),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: Text('Cancel', style: textTheme.labelLarge?.copyWith(color: AppColors.textMedium)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Get.back(result: true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Text('Delete', style: textTheme.labelLarge?.copyWith(color: AppColors.white)),
                                    ),
                                  ],
                                ),
                              ) ?? false;

                              if (confirmed) {
                                await controller.deleteAddress(addr.id!);
                              }
                            } else {
                              Get.snackbar('Error', 'Address ID is missing, cannot delete.', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.danger);
                            }
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
                if (!RegExp(r'^\d{4,10}$').hasMatch(val.trim())) return 'Invalid PIN code (4-10 digits)';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Home', 'Work', 'Other'].map((label) {
                      final isSelected = controller.selectedLabel.value == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) controller.selectedLabel.value = label;
                        },
                        labelStyle: textTheme.labelMedium?.copyWith(
                            color: isSelected ? AppColors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                        backgroundColor: AppColors.neutralBackground,
                        selectedColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryGreen : AppColors.textLight.withOpacity(0.5),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        elevation: 0,
                        pressElevation: 0,
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
              height: 54,
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
                    : Icon(
                  controller.isEditingMode ? Icons.update : Icons.save, // Icon changes based on mode
                  color: AppColors.white,
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await controller.saveAddress(); // Call saveAddress
                    if (success) {
                      // Snackbar logic moved to controller for consistency, but you can keep here too if needed
                      // For now, let controller handle its own snackbars for success/failure
                      // and then refresh
                      // controller.fetchAddresses(); // Called by controller.saveAddress now
                    } else {
                      // Controller should have already shown an error snackbar
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.lightGreen.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                label: Text(
                  controller.isLoading.value
                      ? (controller.isEditingMode ? "Updating..." : "Saving...")
                      : (controller.isEditingMode ? "Update Address" : "Save Address"), // Label changes
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                controller.cancelEditing(); // Call cancelEditing
              },
              child: Text(
                'Cancel',
                style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textMedium, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
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
      style: textTheme.bodyLarge?.copyWith(color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neutralBackground),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.neutralBackground),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.danger, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}