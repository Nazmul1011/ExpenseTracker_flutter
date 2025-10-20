import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../../shared/widgets/snack_bar/app_snack_bar.dart';

/// ================================================================
///                         ERROR UTILITIES
/// ================================================================
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// ================================================================
///                         LOGGER SERVICE
/// ================================================================
class LoggerService {
  // Singleton instance
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Create logger with PrettyPrinter config
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      lineLength: 40,
      colors: true,
      levelColors: PrettyPrinter.defaultLevelColors,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  /// Log info level message
  void info(String message) {
    _logger.i(message);
  }

  /// Log warning level message
  void warn(String message) {
    _logger.w(message);
  }

  /// Log error level message with optional error object and stack trace
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log debug level message
  void debug(String message) {
    _logger.d(message);
  }

  /// Log verbose level message
  void verbose(String message) {
    _logger.t(message);
  }

  /// Log HTTP request method and URI
  void logRequest(String method, Uri uri) {
    _logger.i('📡 REQUEST [$method] → $uri');
  }

  /// Log HTTP headers map
  void logHeaders(Map<String, dynamic> headers) {
    final maskedHeaders = Map<String, dynamic>.from(headers);
    if (maskedHeaders.containsKey('Authorization')) {
      final auth = maskedHeaders['Authorization'].toString();
      final token = auth.replaceFirst('Bearer ', '');
      final masked = token.length > 12
          ? 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 6)}'
          : auth;
      maskedHeaders['Authorization'] = masked;
    }
    _logger.i('📑 HEADERS → $maskedHeaders');
  }

  /// Log HTTP payload (request body or form data)
  void logPayload(dynamic payload) {
    if (payload == null) {
      _logger.i('📦 PAYLOAD → <empty>');
      return;
    }

    // Pretty-print JSON-like maps/lists
    if (payload is Map || payload is List) {
      try {
        _logger.i('📦 PAYLOAD → ${const JsonEncoder.withIndent('  ').convert(payload)}');
      } catch (_) {
        _logger.i('📦 PAYLOAD → $payload');
      }
      return;
    }

    // Expand Dio FormData (fields + files)
    if (payload is FormData) {
      final fields = <String, String>{for (final e in payload.fields) e.key: e.value};
      // Don't dump raw bytes; summarize each file safely
      final files = payload.files.map((e) {
        final f = e.value;
        return {
          'key': e.key,
          'filename': f.filename,
          'contentType': f.contentType?.toString(),
          // length may be null or expensive; include if available
          'length': (() {
            try { return f.length; } catch (_) { return null; }
          })(),
        };
      }).toList();

      final summarized = {
        'fields': fields,
        'files': files,
      };
      _logger.i('📦 PAYLOAD → ${const JsonEncoder.withIndent('  ').convert(summarized)}');
      return;
    }

    // Fallback
    _logger.i('📦 PAYLOAD → $payload');
  }

  /// Log HTTP response status code and data
  void logResponse(int? statusCode, dynamic data) {
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      _logger.i('✅ RESPONSE [$statusCode] → $data');
    } else if (statusCode != null && statusCode >= 400) {
      _logger.w('⚠️ RESPONSE [$statusCode] → $data');
    } else {
      _logger.e('❌ RESPONSE [$statusCode] → $data');
    }
  }
}

/// ================================================================
///        CONNECTIVITY STREAM SERVICE (Global Subscriber)
/// ================================================================
class ConnectivityService {
  static final ConnectivityService instance = ConnectivityService._internal();
  factory ConnectivityService() => instance;

  final Connectivity connectivity = Connectivity();
  final ValueNotifier<bool> isOnline = ValueNotifier(true);

  ConnectivityService._internal() {
    init();
  }

  void init() {
    // Initial check
    connectivity.checkConnectivity().then((resultList) {
      updateStatus(resultList);
    });

    // Listen to connection changes
    connectivity.onConnectivityChanged.listen((resultList) {
      updateStatus(resultList);
    });
  }

  void updateStatus(List<ConnectivityResult> results) {
    final connected = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);

    if (connected != isOnline.value) {
      isOnline.value = connected;
      showSnack(
        content: connected ? "Back Online" : "No Internet Connection",
        status: connected
            ? SnackBarStatus.connected
            : SnackBarStatus.disconnected,
      );
    }
  }

  void dispose() {
    isOnline.dispose();
  }
}

/// ================================================================
///             AUTH STORAGE SERVICE (using GetStorage)
/// ================================================================
class AuthStorageService {
  final GetStorage storage = GetStorage();

  static const String sessionTokenKey = 'session_token';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  String? get sessionToken => storage.read<String>(sessionTokenKey);
  String? get accessToken => storage.read<String>(accessTokenKey);
  String? get refreshToken => storage.read<String>(refreshTokenKey);

  void setSessionToken(String token) => storage.write(sessionTokenKey, token);
  void setAccessToken(String token) => storage.write(accessTokenKey, token);
  void setRefreshToken(String token) => storage.write(refreshTokenKey, token);

  void setTokens({
    required String sessionToken,
    required String accessToken,
    required String refreshToken,
  }) {
    setSessionToken(sessionToken);
    setAccessToken(accessToken);
    setRefreshToken(refreshToken);
  }

  void clearTokens() {
    storage.remove(sessionTokenKey);
    storage.remove(accessTokenKey);
    storage.remove(refreshTokenKey);
  }

  void logOut() {
    LoggerService().info('[AuthStorageService] Logging out...');
    clearTokens();
  }
}

/// ================================================================
///         TOKEN CONTROLLER (inherits AuthStorageService)
/// ================================================================
class TokenController extends AuthStorageService {}

/// ================================================================
///                         API SERVICE
/// ================================================================
enum ApiType { public, private }

class ApiService {
  static final ApiService instance = ApiService.internal();
  factory ApiService() => instance;

  late final Dio publicClient;
  late final Dio privateClient;

  final TokenController tokenController = TokenController();
  final LoggerService logger = LoggerService();

  ApiService.internal() {
    publicClient = createDioClient();
    privateClient = createDioClient();
    setupPublicInterceptors();
    setupPrivateInterceptors();
  }

  Dio createDioClient() {
    return Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  /// ==============================================================
  ///                   PUBLIC CLIENT INTERCEPTORS
  /// ==============================================================
  void setupPublicInterceptors() {
    publicClient.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          logger.logRequest(options.method, options.uri);
          logger.logHeaders(options.headers);
          logger.logPayload(options.data);
          handler.next(options);
        },
        onResponse: (response, handler) {
          logger.logResponse(response.statusCode, response.data);
          handler.next(response);
        },
        onError: (e, handler) {
          if (e.type == DioExceptionType.connectionError ||
              e.message?.toLowerCase().contains('failed host lookup') == true) {
            logger.error('[PUBLIC API ERROR] Connection Error');
            showSnack(
              content: 'Check your internet or try again later',
              status: SnackBarStatus.error,
            );
          } else {
            logger.error('[PUBLIC API ERROR] ${e.message}');
            showSnack(
              content: 'Something went wrong. Please try again.',
              status: SnackBarStatus.error,
            );
          }
          handler.next(e);
        },
      ),
    ]);
  }

  /// ==============================================================
  ///                   PRIVATE CLIENT INTERCEPTORS
  /// ==============================================================
  void setupPrivateInterceptors() {
    privateClient.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenController.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          logger.logRequest(options.method, options.uri);
          logger.logHeaders(options.headers);
          logger.logPayload(options.data);
          handler.next(options);
        },
        onResponse: (response, handler) {
          logger.logResponse(response.statusCode, response.data);
          if (response.statusCode == 401 ||
              (response.statusCode == 403 && isUnauthorizedError(response.data))) {
            logger.error('[PRIVATE API] Unauthorized response. Logging out.');
            tokenController.logOut();
          }
          handler.next(response);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401 ||
              (e.response?.statusCode == 403 && isUnauthorizedError(e.response?.data))) {
            logger.error('[PRIVATE API ERROR] Unauthorized (onError). Logging out.');
            tokenController.logOut();
          }

          if (e.type == DioExceptionType.connectionError ||
              e.message?.toLowerCase().contains('failed host lookup') == true) {
            logger.error('[PRIVATE API ERROR] Connection Error: ${e.message}');
            showSnack(
              content: 'Check your internet or try again later',
              status: SnackBarStatus.disconnected,
            );
          } else {
            logger.error('[PRIVATE API ERROR] ${e.message}');
          }
          handler.next(e);
        },
      ),
    ]);
  }

  static bool isUnauthorizedError(dynamic data) {
    if (data is Map && data['error'] == 'Unauthorized') return true;
    return false;
  }

  Dio getClient(ApiType apiType, [String? overrideBaseUrl]) {
    final base = apiType == ApiType.public ? publicClient : privateClient;
    if (overrideBaseUrl != null && overrideBaseUrl.isNotEmpty) {
      return Dio(base.options.copyWith(baseUrl: overrideBaseUrl));
    }
    return base;
  }

  void handleError(Response response) {
    final status = response.statusCode ?? 0;
    if (status >= 400) {
      final data = response.data;
      String message = 'Unexpected error';

      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ??
            data['error']?.toString() ??
            (data['errors'] is Map
                ? (data['errors'] as Map).values.first?.first?.toString() ?? 'Invalid data'
                : 'Something went wrong');
      } else {
        message = data.toString();
      }

      throw AppException(message);
    }
  }

  /// ==============================================================
  ///                        HTTP METHODS
  /// ==============================================================
  Future<Response> get(String path,
      {Map<String, dynamic>? query,
      ApiType apiType = ApiType.private,
      String? overrideBaseUrl}) async {
    final client = getClient(apiType, overrideBaseUrl);
    final response = await client.get(path, queryParameters: query);
    handleError(response);
    return response;
  }

  Future<Response> post(String path,
      {dynamic data, ApiType apiType = ApiType.private}) async {
    final response = await getClient(apiType).post(path, data: data);
    handleError(response);
    return response;
  }

  Future<Response> patch(String path,
      {dynamic data, ApiType apiType = ApiType.private}) async {
    final response = await getClient(apiType).patch(path, data: data);
    handleError(response);
    return response;
  }

  Future<Response> put(String path,
      {dynamic data, ApiType apiType = ApiType.private}) async {
    final response = await getClient(apiType).put(path, data: data);
    handleError(response);
    return response;
  }

  Future<Response> delete(String path,
      {dynamic data, ApiType apiType = ApiType.private}) async {
    final response = await getClient(apiType).delete(path, data: data);
    handleError(response);
    return response;
  }
}
