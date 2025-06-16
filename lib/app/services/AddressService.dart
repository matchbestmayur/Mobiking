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
    fetchUserAddresses();
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

      print('GET Status: ${response.statusCode}');
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          body['success'] == true &&
          body['data'] is List) {
        final List data = body['data'];
        print('Fetched ${data.length} addresses.');
        return data.map((e) => AddressModel.fromJson(e)).toList();
      }

      final errorMsg = body['message'] ?? 'Failed to fetch addresses.';
      _showError('Error', errorMsg);
    } catch (e) {
      print('Exception: $e');
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          Get.snackbar('Success', 'Address added successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade600,
              colorText: Colors.white);
          print('AddressService: Address added successfully: ${body['data']['_id']}');
          return AddressModel.fromJson(body['data']);
        } else {
          print('AddressService: Unexpected response format for add: $body');
          Get.snackbar('Error', 'Failed to add address. Invalid response format.',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
        }
      } else if (response.statusCode == 401) {
        print('AddressService: Unauthorized access (401) - Token expired or invalid.');
        Get.snackbar('Session Expired', 'Please log in again.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
      }
      else {
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
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
      }
    } catch (e) {
      print('AddressService: Exception in POST: $e');
      Get.snackbar('Network Error', 'Failed to connect to server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
    }

    return null;
  }
}