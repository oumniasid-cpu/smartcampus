import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions.dart';

/// Central Dio client with:
/// - Auth token injection
/// - Request/response logging (debug only)
/// - Unified error mapping → [AppException]
class ApiClient {
  ApiClient._();

  static Dio create({
    required FlutterSecureStorage secureStorage,
    String baseUrl = 'https://jsonplaceholder.typicode.com',
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(secureStorage),
      if (kDebugMode) _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

// ─── Auth Interceptor ────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const _tokenKey = 'auth_token';

  _AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ─── Logging Interceptor (debug only) ───────────────────────────────────────
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ [${options.method}] ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← [${response.statusCode}] ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✗ [${err.type}] ${err.requestOptions.uri}: ${err.message}');
    handler.next(err);
  }
}

// ─── Error Interceptor ───────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        handler.reject(_wrap(err, const NetworkException('Délai de connexion dépassé.')));
        return;
      case DioExceptionType.connectionError:
        handler.reject(_wrap(err, const NetworkException('Pas de connexion réseau.')));
        return;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode ?? 0;
        if (code == 401) {
          handler.reject(_wrap(err, const AuthException('Session expirée. Reconnectez-vous.')));
        } else if (code >= 500) {
          handler.reject(_wrap(err, ServerException('Erreur serveur ($code).')));
        } else {
          handler.reject(_wrap(err, ServerException('Requête invalide ($code).')));
        }
        return;
      default:
        handler.next(err);
    }
  }

  DioException _wrap(DioException original, Exception cause) {
    return DioException(
      requestOptions: original.requestOptions,
      error: cause,
      type: original.type,
      response: original.response,
    );
  }
}