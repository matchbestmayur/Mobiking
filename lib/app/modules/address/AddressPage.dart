import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/address_controller.dart';
import '../../data/AddressModel.dart';

class AddressPage extends StatelessWidget {
  AddressPage({Key? key}) : super(key: key) {
    Get.put(AddressController());
  }

  final AddressController controller = Get.find<AddressController>();

  final _formKey = GlobalKey<FormState>();

  final Color appDeepPurple = const Color(0xFF6B1EFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'Manage Addresses',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: appDeepPurple,
        elevation: 1,
      ),
      floatingActionButton: Obx(() {
        if (!controller.isAddingAddress.value && !controller.isLoading.value) {
          return FloatingActionButton(
            backgroundColor: appDeepPurple,
            onPressed: () {
              controller.isAddingAddress.value = true;
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: Obx(() {
        if (controller.isAddingAddress.value) {
          return _buildForm(context);
        } else if (controller.isLoading.value && controller.addresses.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: appDeepPurple),
          );
        } else if (controller.addresses.isEmpty) {
          
          return RefreshIndicator( 
            onRefresh: () async {
              await controller.fetchAddresses(); 
            },
            color: appDeepPurple,
            child: SingleChildScrollView( 
              physics: const AlwaysScrollableScrollPhysics(), 
              child: SizedBox( 
                height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top, 
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No addresses found.',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add your first address,',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      Text(
                        'or pull down to refresh.', 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return _buildAddressList();
        }
      }),
    );
  }

  
  Widget _buildAddressList() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchAddresses();
      },
      color: appDeepPurple,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final AddressModel addr = controller.addresses[index];
          final bool isSelected = controller.selectedAddress.value?.id == addr.id;

          return GestureDetector(
            onTap: () {
              controller.selectAddress(addr);
              Get.back();
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(color: appDeepPurple, width: 2.0)
                    : BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              elevation: isSelected ? 4 : 1,
              shadowColor: isSelected ? appDeepPurple.withOpacity(0.3) : Colors.black.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getEmojiForLabel(addr.label)} ${addr.label}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: appDeepPurple),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          addr.street,
                          style: GoogleFonts.poppins(fontSize: 14.5, color: Colors.grey[800], height: 1.4),
                        ),
                        Text(
                          '${addr.city}, ${addr.state} - ${addr.pinCode}',
                          style: GoogleFonts.poppins(fontSize: 14.5, color: Colors.grey[800], height: 1.4),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Icon(Icons.check_circle, color: appDeepPurple, size: 26),
                      ),
                  ],
                ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              label: "Street Address, House No.",
              controller: controller.streetController,
              validator: (val) => val == null || val.trim().isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "City",
              controller: controller.cityController,
              validator: (val) => val == null || val.trim().isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "State / Province",
              controller: controller.stateController,
              validator: (val) => val == null || val.trim().isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: "PIN Code / Postal Code",
              keyboardType: TextInputType.number,
              controller: controller.pinCodeController,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required field';
                if (!RegExp(r'^\d{4,10}$').hasMatch(val.trim())) return 'Invalid PIN code';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(() {
              return Column(
                children: [
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
                        labelStyle: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : appDeepPurple,
                            fontWeight: FontWeight.w600),
                        backgroundColor: Colors.white,
                        selectedColor: appDeepPurple,
                        shape: StadiumBorder(side: BorderSide(color: appDeepPurple)),
                        elevation: isSelected ? 2 : 0,
                      );
                    }).toList(),
                  ),
                  if (controller.selectedLabel.value == 'Other') ...[
                    const SizedBox(height: 16),
                    _buildTextField(
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
              height: 50,
              child: Obx(() => ElevatedButton.icon(
                icon: controller.isLoading.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save_alt_outlined, color: Colors.white),
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await controller.addAddress();
                    if (success) {
                      
                      
                      
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appDeepPurple,
                  disabledBackgroundColor: appDeepPurple.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Text(
                  controller.isLoading.value ? "Saving..." : "Save Address",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                style: GoogleFonts.poppins(
                    color: appDeepPurple, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appDeepPurple, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade600, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}