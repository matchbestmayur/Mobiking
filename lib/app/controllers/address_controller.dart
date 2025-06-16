import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/AddressModel.dart';
import '../services/AddressService.dart'; // Assume this path is correct

class AddressController extends GetxController {

  final AddressService _addressService = Get.find<AddressService>(); // Use Get.find for existing service if already put

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxBool isAddingAddress = false.obs;
  final RxBool isLoading = false.obs;

  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController customLabelController = TextEditingController();

  final RxString selectedLabel = 'Home'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  @override
  void onClose() {
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    customLabelController.dispose();
    super.onClose();
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      final fetchedList = await _addressService.fetchUserAddresses();
      addresses.assignAll(fetchedList);
    } catch (e) {
      print('AddressController: Error fetching addresses: $e');
      Get.snackbar(
        'Fetch Failed',
        'Could not load addresses. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.cloud_off_outlined, color: Colors.white),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        animationDuration: const Duration(milliseconds: 300),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAddress() async {
    isLoading.value = true; // Set loading true at the start
    try {
      String finalLabel = selectedLabel.value;
      if (selectedLabel.value == 'Other') {
        finalLabel = customLabelController.text.trim();
      }

      // --- Validation Checks - Return immediately if failed ---
      if (finalLabel.isEmpty) {
        _showSnackbar(
          'Input Required',
          'Please provide a label for the address (e.g., Home, Work, Other).',
          Colors.amber,
          Icons.label_important_outline,
        );
        return false; // Exit function immediately
      }

      if (streetController.text.trim().isEmpty ||
          cityController.text.trim().isEmpty ||
          stateController.text.trim().isEmpty ||
          pinCodeController.text.trim().isEmpty) {
        _showSnackbar(
          'Input Required',
          'Please fill in all address fields (Street, City, State, Pincode).',
          Colors.amber,
          Icons.edit_road_outlined,
        );
        return false; // Exit function immediately
      }

      // --- Proceed with adding address if validation passes ---
      final newAddress = AddressModel(
        label: finalLabel,
        street: streetController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pinCode: pinCodeController.text.trim(),
      );

      // This line is crucial: _addressService.addAddress MUST throw an exception on API failure.
      // It should ONLY return a non-null AddressModel on SUCCESS.
      final addedAddress = await _addressService.addAddress(newAddress);

      // If execution reaches here, it means the service call succeeded and returned a non-null address.
      addresses.add(addedAddress!); // Add to observable list
      isAddingAddress.value = false; // Reset adding state
      clearForm(); // Clear form fields
      _showSnackbar(
        'Success!',
        'Your new address "${addedAddress.label}" has been added.',
        Colors.green,
        Icons.location_on_outlined,
      );
      return true; // Indicate success

    } catch (e) {
      // All errors (network, API errors, unhandled exceptions) will land here.
      print('AddressController: Error adding address: $e');
      _showSnackbar(
        'Error',
        'Failed to add address. Please check your internet or try again later.',
        Colors.red,
        Icons.cloud_off_outlined,
      );
      return false; // Indicate failure
    } finally {
      // Ensure loading state is always reset regardless of success or failure
      isLoading.value = false;
    }
  }

  void clearForm() {
    streetController.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();
    customLabelController.clear();
    selectedLabel.value = 'Home';
  }

  // Helper method for consistency
  void _showSnackbar(String title, String message, Color color, IconData icon) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.8),
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      animationDuration: const Duration(milliseconds: 300),
      duration: const Duration(seconds: 3), // Standard duration for all snackbars
    );
  }
}