// Path: lib/services/query_service.dart

import 'dart:convert'; // Required for jsonEncode/decode if needed, though Dio handles most of it.
import 'package:dio/dio.dart'; // Import the Dio package

import '../data/QueryModel.dart'; // Import your QueryModel and related request/response models

class QueryService {
  final Dio _dio; // Dio instance for making HTTP requests

  // IMPORTANT: This base URL should match the base URL of your backend API.
  // Based on your curl command, it is now set to http://localhost:8000/api/v1.
  // If your deployed backend is different, you will need to change this.
  final String _baseUrl = "https://mobiking-e-commerce-backend.vercel.app/api/v1";

  String? _authToken; // Stores the JWT authentication token

  // Constructor for QueryService
  // Takes an optional Dio instance, useful for testing, otherwise creates a new one.
  QueryService({Dio? dio}) : _dio = dio ?? Dio() {
    // Add a LogInterceptor to Dio for detailed logging of requests and responses.
    // This is incredibly useful for debugging network issues.
    _dio.interceptors.add(
      LogInterceptor(
        request: true, // Log request details
        requestHeader: true, // Log request headers
        requestBody: true, // Log request body
        responseHeader: true, // Log response headers
        responseBody: true, // Log response body
        error: true, // Log errors
        logPrint: (obj) => print('DIO LOG: $obj'), // Custom print function for logs
      ),
    );
  }

  // Method to set the authentication token.
  // This token will be added as an Authorization header to all subsequent requests.
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $_authToken';
    print('QueryService: Auth token set in Dio headers: $_authToken');
  }

  // Generic helper method to handle Dio responses and parse them into a specified type T.
  // It handles API response wrappers and various error conditions.
  Future<T> _handleDioResponse<T>(
      Response response,
      T Function(dynamic jsonData) dataParser, // Function to parse the 'data' part of the response
      ) async {
    print('QueryService: _handleDioResponse - Processing response with status: ${response.statusCode}');

    // Check for successful HTTP status codes (2xx range)
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      final dynamic rawResponseData = response.data; // Get the raw response body

      // If the response data is a string and doesn't look like JSON,
      // it's likely an unexpected response (like a redirect HTML page).
      if (rawResponseData is String && !rawResponseData.trim().startsWith('{') && !rawResponseData.trim().startsWith('[')) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse, // Indicate that the response content was bad
          error: 'Backend returned a non-JSON string: "$rawResponseData". Expected JSON.',
        );
      }

      // Try to parse the response as a Map (common for single objects or ApiResponse wrapper)
      if (rawResponseData is Map<String, dynamic>) {
        // Check if it fits the common ApiResponse wrapper structure
        if (rawResponseData.containsKey('statusCode') && rawResponseData.containsKey('message') && rawResponseData.containsKey('data')) {
          // If it's an ApiResponse, parse it using the generic ApiResponse.fromJson
          final apiResponse = ApiResponse<T>.fromJson(rawResponseData, dataParser);
          if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
            // If the wrapped status code is also successful, return the parsed data
            return apiResponse.data;
          } else {
            // If the wrapped status code indicates an error, throw a DioException
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'API Error (${apiResponse.statusCode}): ${apiResponse.message}',
            );
          }
        } else {
          // If it's a Map but doesn't have the ApiResponse wrapper,
          // try to parse the root map directly with the provided dataParser.
          try {
            print('QueryService: _handleDioResponse - Attempting direct dataParser on raw Map (no ApiResponse wrapper).');
            return dataParser(rawResponseData);
          } catch (e) {
            // If direct parsing fails, throw an error
            throw DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'Received JSON object, but could not parse with dataParser: $e. Data: $rawResponseData',
            );
          }
        }
      } else if (rawResponseData is List<dynamic>) {
        // If the response is a direct JSON list (e.g., for getMyQueries),
        // try to parse it directly with the dataParser.
        try {
          print('QueryService: _handleDioResponse - Attempting direct dataParser on raw List.');
          return dataParser(rawResponseData);
        } catch (e) {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Received JSON list, but could not parse with dataParser: $e. Data: $rawResponseData',
          );
        }
      } else {
        // Handle any other unexpected root data types (e.g., null, numbers, booleans if not expected)
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unexpected root response data type: ${rawResponseData.runtimeType}. Content: $rawResponseData',
        );
      }
    } else {
      // If the HTTP status code is outside the 2xx range, it's an HTTP error from the server.
      String errorMessage = 'Unknown HTTP Error';
      // Attempt to extract a specific message from the error response body if available.
      if (response.data is Map && response.data.containsKey('message')) {
        errorMessage = response.data['message'].toString();
      } else if (response.data != null) {
        errorMessage = response.data.toString();
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: errorMessage,
      );
    }
  }

  // --- API Methods using Dio ---

  // Method to raise a new query
  Future<QueryModel> raiseQuery({
    required String title,
    required String message,
  }) async {
    final url = '$_baseUrl/queries/raiseQuery'; // Full endpoint for raising a query
    final requestBody = RaiseQueryRequestModel(title: title, description: message).toJson();

    try {
      final response = await _dio.post(
        url,
        data: requestBody, // Send request body as JSON
      );
      // Handle the response, expecting a QueryModel back
      return _handleDioResponse(response, (json) => QueryModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      print('QueryService: Error in raiseQuery: ${e.response?.data ?? e.message}');
      throw Exception('Failed to raise query: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // Method to rate an existing query
  Future<QueryModel> rateQuery({
    required String queryId,
    required int rating,
    String? review, // Optional review text
  }) async {
    final url = '$_baseUrl/queries/$queryId/rate'; // Endpoint for rating a specific query
    final requestBody = RateQueryRequestModel(rating: rating, review: review).toJson();

    try {
      final response = await _dio.post(
        url,
        data: requestBody,
      );
      return _handleDioResponse(response, (json) => QueryModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      print('QueryService: Error in rateQuery: ${e.response?.data ?? e.message}');
      throw Exception('Failed to rate query: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // UPDATED: Method to reply to a query.
  // It now sends `queryId` and `message` in the request body to a fixed `/reply` endpoint.
  Future<QueryModel> replyToQuery({
    required String queryId,
    required String replyText, // This will be mapped to 'message' in the request
  }) async {
    // Corrected URL based on your curl command: fixed /reply endpoint.
    final url = '$_baseUrl/queries/reply';
    // Use the updated ReplyQueryRequestModel which includes queryId and uses 'message'.
    final requestBody = ReplyQueryRequestModel(queryId: queryId, message: replyText).toJson();

    try {
      final response = await _dio.post(
        url,
        data: requestBody, // Send the body containing queryId and message
      );
      return _handleDioResponse(response, (json) => QueryModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      print('QueryService: Error in replyToQuery: ${e.response?.data ?? e.message}');
      throw Exception('Failed to reply to query: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // Method to get all queries for the current user
  Future<List<QueryModel>> getMyQueries() async {
    final url = '$_baseUrl/queries/my'; // Endpoint for getting user's queries

    try {
      final response = await _dio.get(url);
      // Handle the response, expecting a list of QueryModel
      return _handleDioResponse(
        response,
            (jsonList) => (jsonList as List<dynamic>)
            .map((item) => QueryModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      print('QueryService: Error in getMyQueries: ${e.response?.data ?? e.message}');
      throw Exception('Failed to load queries: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // Method to get a single query by its ID
  Future<QueryModel> getQueryById(String queryId) async {
    final url = '$_baseUrl/queries/$queryId'; // Endpoint for getting a specific query by ID
    try {
      final response = await _dio.get(url);
      return _handleDioResponse(response, (json) => QueryModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      print('QueryService: Error in getQueryById: ${e.response?.data ?? e.message}');
      throw Exception('Failed to get query by ID: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // UPDATED: Method to mark a query as read.
  // It now sends `queryId` in the request body to a fixed `/read` endpoint (hypothetical).
  // IMPORTANT: Confirm the actual endpoint and expected body for "mark as read" on your backend.
  Future<QueryModel> markQueryAsRead(String queryId) async {
    // Assuming a fixed endpoint like /queries/read and queryId in body for marking as read.
    // Adjust this URL and request body if your backend has a different structure for this.
    final url = '$_baseUrl/queries/read';
    final requestBody = {'queryId': queryId}; // Send queryId in the body

    try {
      // Using PATCH for partial update (marking as read is a state change)
      final response = await _dio.patch(
        url,
        data: requestBody, // Send queryId in the body
      );
      // If the backend returns a successful response with the updated QueryModel, parse it.
      // If it returns 204 No Content, you might need to fetch the query again or update locally.
      return _handleDioResponse(response, (json) => QueryModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      print('QueryService: Error marking query $queryId as read: ${e.response?.data ?? e.message}');
      throw Exception('Failed to mark query as read: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  // Method to update the status of a query (e.g., 'open', 'closed')
  Future<QueryModel> updateQueryStatus({
    required String queryId,
    required String status,
  }) async {
    final url = '$_baseUrl/queries/$queryId/status'; // Endpoint for updating query status
    final requestBody = {'status': status}; // Send status in the body

    try {
      final response = await _dio.put(
        url,
        data: requestBody,
      );
      return _handleDioResponse(response, (json) => QueryModel.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      print('QueryService: Error in updateQueryStatus: ${e.response?.data ?? e.message}');
      throw Exception('Failed to update status: ${e.response?.data?['message'] ?? e.message}');
    }
  }
}