import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'session_store.dart';

final Dio apiClient = Dio(
  BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ),
)..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SessionStore.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            'HRHubApi ${response.requestOptions.method} '
            '${response.requestOptions.path} -> ${response.statusCode}',
          );
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          // Never logs credentials — only the endpoint, status and the
          // server's own message.
          debugPrint(
            'HRHubApi ${error.requestOptions.method} '
            '${error.requestOptions.path} -> '
            '${error.response?.statusCode ?? error.type.name} '
            '${error.response?.data ?? error.message}',
          );
        }
        // Mirrors the web client: a rejected token drops us back to login.
        if (error.response?.statusCode == 401) {
          SessionStore.clearToken();
          SessionStore.onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

/// Pulls the readable message out of a Dio failure for display in the UI.
String apiErrorMessage(Object error, {required String fallback}) {
  if (error is! DioException) return fallback;
  final data = error.response?.data;
  if (data is Map && data['detail'] is String) return data['detail'] as String;
  if (data is Map && data['detail'] is List) {
    final first = (data['detail'] as List).firstOrNull;
    if (first is Map && first['msg'] is String) return first['msg'] as String;
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.connectionError) {
    return "Can't reach the server. Is the backend running?";
  }
  return fallback;
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
