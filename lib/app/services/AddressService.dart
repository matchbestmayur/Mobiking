import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

import '../data/AddressModel.dart';

class AddressService extends GetxService {
  final _box = GetStorage();
  // Ensure these URLs are correct for your backend
  final _addUrl = Uri.parse('https://mobiking-e-commerce-backend.vercel.app/api/v1/users/address/add');
  final _viewUrl = Uri.parse('https://mobiking-e-commerce-backend.vercel.app/api/v1/users/address/view');

  @override
  void onInit() {
    super.onInit();
    // No need to fetch here if it's fetched in controller's onInit, to avoid double-fetch
    // fetchUserAddresses();
  }

  String? _getAccessToken() {
    final token = _box.read('accessToken');
    if (token == null) {
      print('AddressService: Authorization token not found in GetStorage.');
    }
    return token;
  }

  Future<List<AddressModel>> fetchUserAddresses() async {
    final token = _getAccessToken();
    if (token == null) {
      _showError('Authentication Error', 'Please log in to view addresses.');
      return [];
    }

    try {
      final response = await http.get(_viewUrl, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      print('AddressService: GET Status: ${response.statusCode}');
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        // The view endpoint returns user data which contains an 'address' list
        if (body['data'] is Map && body['data']['address'] is List) {
          final List addressListJson = body['data']['address'];
          print('AddressService: Fetched ${addressListJson.length} addresses.');
          return addressListJson.map((e) => AddressModel.fromJson(e)).toList();
        } else {
          print('AddressService: Unexpected format for fetch response data: $body');
          _showError('Error', 'Failed to parse address data.');
          return [];
        }
      }

      final errorMsg = body['message'] ?? 'Failed to fetch addresses.';
      _showError('Error', errorMsg);
    } catch (e) {
      print('AddressService: Exception during fetch: $e');
      _showError('Network Error', 'Unable to connect to server.');
    }
    return [];
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
    );
  }

  Future<AddressModel?> addAddress(AddressModel address) async {
    final token = _getAccessToken();
    if (token == null) {
      Get.snackbar('Authentication Error', 'Please log in to add address.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      return null;
    }

    try {
      final response = await http.post(
        _addUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(address.toJson()),
      );

      print('AddressService: POST Status ${response.statusCode}');
      print('AddressService: Raw response body on add: ${response.body}'); // Keep for debugging

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] is Map) {
          final userData = body['data'];
          // CRITICAL FIX: Extract the address list from userData
          if (userData['address'] is List && userData['address'].isNotEmpty) {
            // Assuming the newly added address is the last one in the list
            final newAddressJson = userData['address'].last;
            Get.snackbar('Success', 'Address added successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade600,
                colorText: Colors.white);
            print('AddressService: Address added successfully (parsed from list): ${newAddressJson['_id']}');
            return AddressModel.fromJson(newAddressJson); // Pass the correct individual address map
          } else {
            print('AddressService: Add response data missing address list or empty: $body');
            _showError('Error', 'Address added but details not returned correctly.');
            return null; // Data structure not as expected
          }
        } else {
          print('AddressService: Unexpected response format for add success: $body');
          _showError('Error', 'Failed to add address. Invalid response format.');
          return null; // Success true but data is null or not a Map
        }
      } else if (response.statusCode == 401) {
        print('AddressService: Unauthorized access (401) - Token expired or invalid.');
        _showError('Session Expired', 'Please log in again.');
        return null;
      } else {
        String errorMessage = 'Failed to add address';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody != null && errorBody['message'] != null) {
            errorMessage = errorBody['message'];
          }
        } catch (_) {
          errorMessage = 'Server error (Status: ${response.statusCode})';
        }
        print('AddressService: Failed to add address. Status ${response.statusCode}, Body: ${response.body}');
        _showError('Error', errorMessage);
        return null;
      }
    } catch (e) {
      print('AddressService: Exception in POST (addAddress): $e');
      _showError('Network Error', 'Failed to connect to server.');
      return null;
    }
  }
}