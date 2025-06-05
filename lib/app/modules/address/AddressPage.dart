import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final box = GetStorage();

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final customLabelController = TextEditingController();

  final Color appDeepPurple = const Color(0xFF6B1EFF);
  final RxString selectedLabel = 'Home'.obs;

  // UI State: true = show form, false = show address list
  final RxBool isAddingAddress = false.obs;

  // Helper: get addresses from storage
  List<Map<String, dynamic>> get addresses {
    final List? stored = box.read<List>('addresses');
    if (stored == null) return [];
    return stored.cast<Map<String, dynamic>>();
  }

  // Save address
  void saveAddress() {
    if (!_formKey.currentState!.validate()) return;

    final label = selectedLabel.value == 'Other'
        ? (customLabelController.text.trim().isEmpty ? 'Other' : customLabelController.text.trim())
        : selectedLabel.value;

    final newAddress = {
      'fullName': fullNameController.text.trim(),
      'phoneNumber': phoneNumberController.text.trim(),
      'street': streetController.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'pinCode': pinCodeController.text.trim(),
      'label': label,
    };

    final currentAddresses = addresses;
    currentAddresses.add(newAddress);
    box.write('addresses', currentAddresses);

    fullNameController.clear();
    phoneNumberController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();
    customLabelController.clear();
    selectedLabel.value = 'Home';
    isAddingAddress.value = false;

    Get.snackbar(
      'Success',
      'Address saved locally!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    customLabelController.dispose();
    super.dispose();
  }

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
          'Your Addresses',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: appDeepPurple,
      ),
      floatingActionButton: Obx(() {
        if (!isAddingAddress.value) {
          return FloatingActionButton(
            backgroundColor: appDeepPurple,
            onPressed: () {
              isAddingAddress.value = true;
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      body: Obx(() {
        if (isAddingAddress.value) {
          return _buildForm();
        } else {
          final savedAddresses = addresses;
          if (savedAddresses.isEmpty) {
            return Center(
              child: Text(
                'No addresses saved yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey.shade700),
              ),
            );
          } else {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedAddresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final addr = savedAddresses[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${addr['label'].toString().toLowerCase() == 'home' ? '🏠' : addr['label'].toString().toLowerCase() == 'office' ? '🏢' : '🏷️'} ${addr['label']} - ${addr['fullName']}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📍 ${addr['street']}, ${addr['city']}, ${addr['pinCode']}',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }
      }),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(label: "Full Name", controller: fullNameController),
            const SizedBox(height: 16),
            _buildTextField(
              label: "Phone Number",
              keyboardType: TextInputType.phone,
              controller: phoneNumberController,
            ),
            const SizedBox(height: 16),
            _buildTextField(label: "Street Address", controller: streetController),
            const SizedBox(height: 16),
            _buildTextField(label: "City", controller: cityController),
            const SizedBox(height: 16),
            _buildTextField(label: "State", controller: stateController),
            const SizedBox(height: 16),
            _buildTextField(
              label: "PIN Code",
              keyboardType: TextInputType.number,
              controller: pinCodeController,
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['Home', 'Office', 'Other'].map((label) {
                      final isSelected = selectedLabel.value == label;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            selectedLabel.value = label;
                            if (label != 'Other') {
                              customLabelController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? appDeepPurple : Colors.white,
                            foregroundColor: isSelected ? Colors.white : Colors.black,
                            side: BorderSide(color: appDeepPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: isSelected ? 4 : 0,
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (selectedLabel.value == 'Other') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: customLabelController,
                      decoration: InputDecoration(
                        labelText: 'Custom Label',
                        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: appDeepPurple.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: appDeepPurple, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        selectedLabel.value = value.trim().isEmpty ? 'Other' : value.trim();
                      },
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appDeepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  "Save Address",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                isAddingAddress.value = false;
                fullNameController.clear();
                phoneNumberController.clear();
                streetController.clear();
                cityController.clear();
                stateController.clear();
                pinCodeController.clear();
                customLabelController.clear();
                selectedLabel.value = 'Home';
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: appDeepPurple, fontWeight: FontWeight.w600),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.trim().isEmpty ? 'Required field' : null,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appDeepPurple.withOpacity(0.6)),
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
