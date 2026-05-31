import 'dart:io';
import 'package:dio/dio.dart';

class ErrorHelper {
  /// Translates any [DioException] or general exception into a user-friendly,
  /// descriptive, yet specific error message.
  static String getReadableErrorMessage(dynamic e) {
    if (e is! DioException) {
      return e?.toString().replaceAll('Exception: ', '') ?? "An unexpected error occurred.";
    }

    final statusCode = e.response?.statusCode;

    // 1. Handle Response Errors (status codes)
    if (e.response != null) {
      final data = e.response?.data;

      // If the response is a JSON Map, extract standard backend messages
      if (data is Map<String, dynamic>) {
        if (data['errors'] != null) {
          return "Validation Error: ${data['errors']}";
        }
        final message = data['message'] ?? data['detail'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }

      // If no custom message in response, map by standard HTTP status codes
      switch (statusCode) {
        case 400:
          return "Bad Request (400): The server could not process the request. Please verify your input.";
        case 401:
          return "Session Expired or Unauthorized (401). Please log in again.";
        case 403:
          return "Access Denied (403): You do not have permission to perform this action.";
        case 404:
          return "Not Found (404): The requested resource could not be located on the server.";
        case 409:
          return "Conflict (409): A conflict occurred with the current state of the resource.";
        case 422:
          return "Unprocessable Entity (422): The server understood the request but could not process the instructions.";
        case 500:
          return "Internal Server Error (500): Something went wrong on our server. Our team has been notified.";
        case 502:
          return "Server Temporarily Offline (Bad Gateway 502). Please try again shortly.";
        case 503:
          return "Service Under Maintenance (503). The server is temporarily unavailable. Please try again soon.";
        case 504:
          return "Gateway Timeout (504): The server took too long to respond. Please check your connection and try again.";
        default:
          return "Server error (Code $statusCode). Please try again later.";
      }
    }

    // 2. Handle Connection / Timeout / Network Issues
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet stability and try again.";
      case DioExceptionType.connectionError:
        return "Connection failed. Please check your internet connection and ensure the server is online.";
      case DioExceptionType.cancel:
        return "The request was cancelled.";
      case DioExceptionType.badCertificate:
        return "A secure connection could not be established (invalid SSL certificate).";
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException || e.toString().contains('SocketException')) {
          return "Network unreachable. Please check your internet connection.";
        }
        return e.message ?? "A network error occurred. Please try again.";
    }
  }
}
