// // api_client.dart

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';

// //api_client
// class ApiClient {
//   final Dio _dio;

//   // Singleton for global use
//   static final ApiClient _instance = ApiClient._internal();
//   factory ApiClient() => _instance;

//   ApiClient._internal()
//       : _dio = Dio(BaseOptions(
//           baseUrl:
//               // "https://cxo.droidal.com/",
//               "http://192.168.59.51:8000/",
//           connectTimeout: const Duration(seconds: 60),
//           receiveTimeout: const Duration(seconds: 60),
//           headers: {
//             'Content-Type': 'application/json',
//           },
//         )) {
//     // SSL cert validation bypass (only for development/testing!)
//     (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
//         (client) {
//       client.badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//       return client;
//     };

//     // Optional: Add interceptors for logging, headers, etc.
//     _dio.interceptors.add(LogInterceptor(responseBody: true));
//   }

//   Dio get dio => _dio;

// }

// api_client.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- NEW IMPORT

//api_client
class ApiClient {
  final Dio _dio;
  // Key for token storage
  static const String _tokenKey = 'auth_token';

  // Singleton for global use
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal()
      : _dio = Dio(BaseOptions(
            //baseUrl: "https://cxo.droidal.com/",
            baseUrl: "http://10.0.2.2:8000/",
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'Content-Type': 'application/json',
            },
          )) {
    // 1. SSL bypass setup (already correct for local HTTPS, but your URL is HTTP)
    // (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   return client;
    // };

    // 2. Add Logging Interceptor
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    
    // 3. Add Authentication Interceptor (THE CRUCIAL ADDITION)
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip adding the token to the Login API itself
        if (options.path.contains('login')) {
          return handler.next(options);
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);

        if (token != null) {
          // Attach the token as a Bearer token for all other requests
          options.headers['Authorization'] = 'Bearer $token'; 
        }

        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  // --- NEW METHODS FOR TOKEN MANAGEMENT ---
  
  // Method to save the token after successful login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Method to clear the token on logout
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}