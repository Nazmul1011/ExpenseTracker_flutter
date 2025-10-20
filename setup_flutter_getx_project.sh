#!/bin/bash

# ==============================================================================
# 🚀 Flutter Project Setup Script with GetX
# This script creates a new Flutter project with a complete GetX architecture
# ==============================================================================

set -e  # Exit on error

# ----------------------------
# 🎯 Configuration
# ----------------------------
echo "=============================================="
echo "🛠️  Flutter Project Setup Wizard"
echo "=============================================="
echo ""

# Ask for project name
read -p "📦 Enter your Flutter project name (e.g. my_app): " PROJECT_NAME
while [[ -z "$PROJECT_NAME" ]]; do
  echo "❌ Project name cannot be empty!"
  read -p "📦 Enter your Flutter project name (e.g. my_app): " PROJECT_NAME
done

# Ask for app title
read -p "🏷️  Enter your app title (e.g. My Awesome App): " APP_TITLE
while [[ -z "$APP_TITLE" ]]; do
  echo "❌ App title cannot be empty!"
  read -p "🏷️  Enter your app title (e.g. My Awesome App): " APP_TITLE
done

# Convert App Title → PascalCase for class name (e.g. "my awesome app" → "MyAwesomeApp")
APP_CLASS_NAME=$(echo "$APP_TITLE" | sed -E 's/[^a-zA-Z0-9 ]//g' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2)}}1' | tr -d ' ')
APP_CLASS_NAME="${APP_CLASS_NAME}"

echo ""
echo "🚀 Creating Flutter project: $PROJECT_NAME"
echo "📱 App title: $APP_TITLE"
echo "🏗️  Generated class name: $APP_CLASS_NAME"
echo ""

# ----------------------------
# 📁 Create Flutter Project
# ----------------------------
flutter create "$PROJECT_NAME"
cd "$PROJECT_NAME"

# ----------------------------
# 🗑️ Remove default files
# ----------------------------
echo "🗑️  Cleaning up default files..."
rm -f lib/main.dart
rm -f test/widget_test.dart

# ----------------------------
# 📂 Create Folder Structure
# ----------------------------
echo "📂 Creating folder structure..."

mkdir -p lib/core/{bindings,controllers,themes,routes,services}
mkdir -p lib/shared/{helpers,mixins,widgets/{scaffold,snack_bar,spacer,text_form_field,progress_loader,app_drop_down_search,material_button,app_bar,material_app}}
mkdir -p assets/{images,fonts,envs}

# ----------------------------
# 📝 Create main.dart
# ----------------------------
echo "📝 Creating main.dart..."
cat > lib/main.dart << 'EOF'
import 'bootstrap.dart';

void main() {
  bootstrap();
}
EOF

# ----------------------------
# 📝 Create bootstrap.dart
# ----------------------------
echo "📝 Creating bootstrap.dart..."
cat > lib/bootstrap.dart <<EOF
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/api_service.dart';
import 'material_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize connectivity listener
  ConnectivityService();

  // Initialize dotenv
  await dotenv.load(fileName: ".env");

  // Initialize GetStorage
  await GetStorage.init();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const $APP_CLASS_NAME());
}
EOF

# ----------------------------
# 📝 Create material_app.dart
# ----------------------------
echo "📝 Creating material_app.dart..."
cat > lib/material_app.dart <<EOF
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/bindings/global_bindings.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'shared/widgets/scaffold/app_scaffold.dart';

class $APP_CLASS_NAME extends StatelessWidget {
  const $APP_CLASS_NAME({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '$APP_TITLE',
      theme: appTheme(context),
      initialBinding: GlobalBindings(),
      initialRoute: AppRoutes.appScaffold,
      getPages: AppPages.pages,
      home: const AppScaffold(),
    );
  }
}
EOF

# ----------------------------
# 📝 Create global_bindings.dart
# ----------------------------
echo "📝 Creating global_bindings.dart..."
cat > lib/core/bindings/global_bindings.dart << 'EOF'
import 'package:get/get.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    // Add global controllers here
  }
}
EOF

# ----------------------------
# 📝 Create base_controller.dart
# ----------------------------
echo "📝 Creating base_controller.dart..."
cat > lib/core/controllers/base_controller.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/snack_bar/app_snack_bar.dart';

mixin BaseController on GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasInternet = true.obs;

  void setLoading(bool value) => isLoading.value = value;

  void setInternetStatus(bool isOnline) => hasInternet.value = isOnline;

  void showError(String message) {
    showSnack(
      content: message,
      status: SnackBarStatus.error,
    );
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}
EOF

# ----------------------------
# 📝 Create app_pages.dart
# ----------------------------
echo "📝 Creating app_pages.dart..."
cat > lib/core/routes/app_pages.dart << 'EOF'
import 'package:get/get.dart';

import '../../shared/widgets/scaffold/app_scaffold.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.appScaffold, page: () => AppScaffold()),
    // Add your pages here
  ];
}
EOF

# ----------------------------
# 📝 Create app_routes.dart
# ----------------------------
echo "📝 Creating app_routes.dart..."
cat > lib/core/routes/app_routes.dart << 'EOF'
abstract class AppRoutes {
  static const appScaffold = '/appScaffold';
  // Add your routes here
}
EOF

# ----------------------------
# 📝 Create app_colors.dart
# ----------------------------
echo "📝 Creating app_colors.dart..."
cat > lib/core/themes/app_colors.dart << 'EOF'
import 'dart:ui';

class AppColors {
  static const Color primaryColor = Color.fromRGBO(81, 193, 92, 1);
  static const Color snackSuccessColor = Color.fromRGBO(228, 255, 252, 1);
  static const Color snackErrorColor = Color.fromRGBO(250, 216, 222, 1);
  static const Color snackWarningColor = Color.fromRGBO(252, 218, 117, 1);
  static const Color snackGeneralColor = Color.fromRGBO(233, 240, 255, 1);
  // Add more colors here
}
EOF

# ----------------------------
# 📝 Create app_theme.dart
# ----------------------------
echo "📝 Creating app_theme.dart..."
cat > lib/core/themes/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: AppColors.primaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD8D9DD)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD8D9DD)),
      ),
      floatingLabelStyle: const TextStyle(color: AppColors.primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    ),
    textTheme: GoogleFonts.robotoFlexTextTheme(),
  );
}
EOF

# ----------------------------
# 📝 Create api_service.dart (Part 1 of 2)
# ----------------------------
echo "📝 Creating api_service.dart..."
cat > lib/core/services/api_service.dart << 'EOF'
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
EOF

# ----------------------------
# 📝 Create base_api_service.dart
# ----------------------------
echo "📝 Creating base_api_service.dart..."
cat > lib/core/services/base_api_service.dart << 'EOF'
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'base_api_response.dart';

abstract class BaseService {
  final ApiService api = ApiService.instance;
  final AuthStorageService tokenController = AuthStorageService();

  Future<BaseApiResponse<T>> safeRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      // Log only status and type, skip raw data to reduce noise
      debugPrint('safeRequest: statusCode=${response.statusCode}, dataType=${data.runtimeType}');

      if (data is List && fromJson != null) {
        try {
          final parsedData = fromJson(data);
          // Log only summary info, e.g. list length or type, not full data
          debugPrint('safeRequest: parsed list with length=${(data).length}');
          return BaseApiResponse<T>(
            success: true,
            message: 'null',
            data: parsedData,
          );
        } catch (parseError, parseStack) {
          debugPrint('safeRequest: Parsing error (List): $parseError');
          if (kDebugMode) debugPrint('StackTrace: $parseStack');
          return BaseApiResponse<T>(
            success: false,
            message: 'Parsing error: $parseError',
            data: null,
          );
        }
      }

      try {
        final parsedResponse = BaseApiResponse<T>.fromJson(data, fromJson);
        debugPrint('safeRequest: parsed BaseApiResponse with success=${parsedResponse.success}');
        return parsedResponse;
      } catch (parseError, parseStack) {
        debugPrint('safeRequest: Parsing error: $parseError');
        if (kDebugMode) debugPrint('StackTrace: $parseStack');
        return BaseApiResponse<T>(
          success: false,
          message: 'Parsing error: $parseError',
          data: null,
        );
      }
    } on AppException catch (e) {
      debugPrint('safeRequest: AppException caught: ${e.message}');
      return BaseApiResponse<T>(
        success: false,
        message: e.message,
        data: null,
      );
    } on DioException catch (e) {
      final isConnectionError = e.type == DioExceptionType.connectionError ||
          (e.message?.toLowerCase().contains('failed host lookup') ?? false);

      debugPrint('safeRequest: DioException caught: ${e.message}');
      debugPrint('safeRequest: isConnectionError: $isConnectionError');

      return BaseApiResponse<T>(
        success: false,
        message: isConnectionError
            ? 'Check your internet or try again later'
            : 'Something went wrong. Please try again',
        data: null,
      );
    } catch (e, stackTrace) {
      debugPrint('safeRequest: Unknown error caught: $e');
      if (kDebugMode) debugPrint('StackTrace: $stackTrace');
      return BaseApiResponse<T>(
        success: false,
        message: 'Something went wrong. Please try again',
        data: null,
      );
    }
  }
}
EOF

# ----------------------------
# 📝 Create base_api_response.dart
# ----------------------------
echo "📝 Creating base_api_response.dart..."
cat > lib/core/services/base_api_response.dart << 'EOF'
class BaseApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  BaseApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return BaseApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: fromJson != null && json['data'] != null
          ? fromJson(json['data'])
          : null,
    );
  }
}
EOF

# ----------------------------
# 📝 Create form_field_validators.dart
# ----------------------------
echo "📝 Creating form_field_validators.dart..."
cat > lib/shared/helpers/form_field_validators.dart << 'EOF'
import '../widgets/text_form_field/app_text_form_field.dart';

String? validateField(String? value, FormFieldType type, [String? originalPassword]) {
  final trimmed = value?.trim() ?? '';
  const int passwordLen = 8;

  if (trimmed.isEmpty) {
    if (type == FormFieldType.email) return 'Email is required';
    if (type == FormFieldType.phone) return 'Phone is required';
    if (type == FormFieldType.password) return 'Password is required';
    if (type == FormFieldType.confirmPassword) return 'Confirm password is required';
    if (type == FormFieldType.number) return 'Number is required';
    if (type == FormFieldType.name) return 'Name is required';
    if (type == FormFieldType.dob) return 'Date of birth is required';
    return 'This field is required';
  }

  if (type == FormFieldType.email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Invalid email address';
    }
  } else if (type == FormFieldType.phone) {
    final phoneRegex = RegExp(r'^(1|3|9)\d{8}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Invalid phone number';
    }
  } else if (type == FormFieldType.password) {
    if (trimmed.length < passwordLen) {
      return 'Password must be at least $passwordLen characters';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(trimmed)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(trimmed)) {
      return 'Password must contain at least one special character';
    }
  } else if (type == FormFieldType.confirmPassword) {
    if (originalPassword != null && trimmed != originalPassword.trim()) {
      return 'Passwords do not match';
    }
  } else if (type == FormFieldType.number) {
    if (double.tryParse(trimmed) == null) {
      return 'Invalid number';
    }
  }

  return null;
}
EOF

# ----------------------------
# 📝 Create input_formatter.dart
# ----------------------------
echo "📝 Creating input_formatter.dart..."
cat > lib/shared/helpers/input_formatter.dart << 'EOF'
import 'package:flutter/services.dart';

import '../widgets/text_form_field/app_text_form_field.dart';

List<TextInputFormatter>? getInputFormatters(FormFieldType type) {
  switch (type) {
    case FormFieldType.name:
      // Only allow letters (a-z, A-Z) and spaces
      return [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]"))];
    case FormFieldType.phone:
      // Allow only digits 0-9
      return [FilteringTextInputFormatter.digitsOnly];
    case FormFieldType.email:
      // Allow all visible characters except whitespace (optional: no formatter here)
      // Usually emails need flexible input, so no formatter or allow wide set
      // But to disallow spaces you can do:
      return [FilteringTextInputFormatter.deny(RegExp(r"\s"))];
    case FormFieldType.number:
      // Allow digits and decimal point (if needed)
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    case FormFieldType.password:
    case FormFieldType.confirmPassword:
      // Usually no formatter, allow all characters
      return null;
    case FormFieldType.dob:
      // Date input — allow digits and slash or dash if used for date input
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9/-]'))];
    case FormFieldType.general:
      return null;
    case FormFieldType.readOnlyDisplay:
      throw UnimplementedError();
  }
}
EOF

# ----------------------------
# 📝 Create app_bar.dart
# ----------------------------
echo "📝 Creating app_bar.dart..."
cat > lib/shared/widgets/app_bar/app_bar.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TheAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Key? appKey;
  final String? title;
  final Widget? titleWidget;
  final bool centerTitle;
  final bool isMultiSelectionMode;
  final int selectedCount;
  final List<Widget>? actions;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool showBackArrow;
  final Color? arrowBackColor;
  final Widget? leadingWidget;
  final bool forceMaterialTransparency;
  final Color? backgroundColor;
  final double? toolbarHeight;
  final double? leadingWidth;
  final double? titleSpacing;
  final TextStyle? titleTextStyle;

  const TheAppBar({
    super.key,
    this.appKey,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.isMultiSelectionMode = false,
    this.selectedCount = 0,
    this.actions,
    this.onSelectAll,
    this.onDeselectAll,
    this.onDelete,
    this.onEdit,
    this.showBackArrow = true,
    this.arrowBackColor,
    this.leadingWidget,
    this.forceMaterialTransparency = true,
    this.backgroundColor,
    this.toolbarHeight,
    this.leadingWidth,
    this.titleSpacing,
    this.titleTextStyle,
  });

  TextStyle get defaultTitleStyle => GoogleFonts.lexend(
        color: const Color(0xFF1F1F1F),
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 0.67,
        letterSpacing: 0.40,
      );

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      key: appKey,
      title: isMultiSelectionMode
          ? Text(
              '$selectedCount Selected',
              style: titleTextStyle ?? defaultTitleStyle,
            )
          : (titleWidget ??
              Text(
                title ?? '',
                style: titleTextStyle ?? defaultTitleStyle,
              )),
      centerTitle: isMultiSelectionMode ? false : centerTitle,
      automaticallyImplyLeading: false,
      leading: showBackArrow
          ? IconButton(
              onPressed: () {
                if (isMultiSelectionMode) {
                  onDeselectAll?.call();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.arrow_back, color: arrowBackColor ?? Colors.black),
            )
          : leadingWidget,
      forceMaterialTransparency: forceMaterialTransparency,
      backgroundColor: backgroundColor,
      toolbarHeight: toolbarHeight ?? 80,
      leadingWidth: leadingWidth,
      titleSpacing: titleSpacing,
      actions: isMultiSelectionMode && selectedCount > 0
          ? <Widget>[
              if (onSelectAll != null)
                IconButton(
                  onPressed: onSelectAll,
                  icon: const Icon(Icons.select_all),
                ),
              if (onDeselectAll != null)
                IconButton(
                  onPressed: onDeselectAll,
                  icon: const Icon(Icons.deselect),
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                ),
              if (selectedCount == 1 && onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                ),
            ]
          : actions,
    );
  }
}
EOF

# ----------------------------
# 📝 Create app_material_button.dart
# ----------------------------
echo "📝 Creating app_material_button.dart..."
cat > lib/shared/widgets/material_button/app_material_button.dart << 'EOF'
import 'package:flutter/material.dart';

import '../progress_loader/progress_loader.dart';

class AppMaterialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final double width;
  final double elevation;
  final double borderRadius;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final Widget? child;

  const AppMaterialButton({
    super.key,
    this.label = 'Material Button',
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 48,
    this.width = double.infinity,
    this.elevation = 0,
    this.borderRadius = 8,
    this.shape,
    this.backgroundColor,
    this.disabledColor,
    this.textColor = Colors.white,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectOnChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: showLoader()
          )
        : Text(label, style: TextStyle(color: textColor));

    final effectiveOnPressed = (isDisabled || isLoading)
        ? null
        : (onPressed ?? () => Navigator.pop(context));

    return MaterialButton(
      onPressed: effectiveOnPressed,
      elevation: elevation,
      color: backgroundColor ?? Theme.of(context).primaryColor,
      disabledColor: disabledColor ?? Theme.of(context).disabledColor,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius)
      ),
      height: height,
      minWidth: width,
      child: child ?? effectOnChild,
    );
  }
}
EOF

# ----------------------------
# 📝 Create app_drop_down_search.dart (Part 1)
# ----------------------------
echo "📝 Creating app_drop_down_search.dart..."
cat > lib/shared/widgets/app_drop_down_search/app_drop_down_search.dart << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppDropdownSearch extends StatefulWidget {
  final List<String> initialItems;
  final String labelText;
  final TextStyle? labelTextStyle;
  final String? hintText;
  final String newItemLabel;
  final String validationText;
  final String dialogTitle;
  final ValueChanged<String?>? onChanged;
  final double dropdownWidth;
  final bool showLabelText;
  final bool showLeadingIcon;
  final bool allowNewItemAddition;
  final bool enabled;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autoValidateMode;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? expandedTrailingIcon;
  final TextStyle? hintTextStyle;
  final Color? clearIconColor;

  const AppDropdownSearch({
    super.key,
    this.controller,
    this.initialItems = const ["Apple", "Banana", "Orange", "Grapes", "Mango"],
    this.labelText = "Select an Item",
    this.labelTextStyle,
    this.hintText,
    this.newItemLabel = "Enter new item",
    this.validationText = "Please enter a new item",
    this.dialogTitle = "Add New Item",
    this.onChanged,
    this.dropdownWidth = double.infinity,
    this.showLabelText = true,
    this.showLeadingIcon = true,
    this.allowNewItemAddition = true,
    this.enabled = true,
    this.validator,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.leadingIcon,
    this.trailingIcon,
    this.expandedTrailingIcon,
    this.hintTextStyle,
    this.clearIconColor,
  });

  @override
  State<AppDropdownSearch> createState() => _AppDropdownSearchState();
}

class _AppDropdownSearchState extends State<AppDropdownSearch> {
  late List<String> items;
  String? selectedItem;
  late TextEditingController itemController;
  final TextEditingController newItemController = TextEditingController();
  final FocusNode menuFocusNode = FocusNode();
  final FocusNode newItemFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FormFieldState<String>? _formFieldState; // Store FormFieldState reference
  String? _lastNotifiedValue; // Track last notified value

  @override
  void initState() {
    super.initState();
    items = List<String>.from(widget.initialItems);
    itemController = widget.controller ?? TextEditingController();

    // Listen to changes in itemController to sync selectedItem
    itemController.addListener(_syncSelectedItemWithController);

    // Initialize selectedItem from controller text at start
    selectedItem = itemController.text.isNotEmpty ? itemController.text : null;

    // Notify FormField state after first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFormField();
    });
  }

  @override
  void didUpdateWidget(covariant AppDropdownSearch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.initialItems, widget.initialItems)) {
      setState(() {
        items = List<String>.from(widget.initialItems);
        if (selectedItem == null || !items.contains(selectedItem)) {
          selectedItem = null;
          itemController.clear();
        }
      });
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_syncSelectedItemWithController);
      itemController = widget.controller ?? TextEditingController();
      itemController.addListener(_syncSelectedItemWithController);
      setState(() {
        selectedItem = itemController.text.isNotEmpty ? itemController.text : null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyFormField();
      });
    }
  }

  void _syncSelectedItemWithController() {
    final text = itemController.text;
    if (text.isEmpty && selectedItem != null) {
      setState(() => selectedItem = null);
    } else if (text.isNotEmpty && selectedItem != text) {
      setState(() => selectedItem = text);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyFormField();
    });
  }

  void _notifyFormField() {
    if (_formFieldState != null && selectedItem != _lastNotifiedValue) {
      _formFieldState!.didChange(selectedItem);
      _lastNotifiedValue = selectedItem;
    }
  }

  void showAddNewItemDialog() {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) => AlertDialog(
        title: Text(widget.dialogTitle),
        content: SizedBox(
          height: 200,
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: newItemController,
                  focusNode: newItemFocusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: widget.newItemLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return widget.validationText;
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTapOutside: (_) => newItemFocusNode.unfocus(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedItem = null;
                itemController.clear();
              });
              newItemController.clear();
              menuFocusNode.unfocus();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newItem = newItemController.text.trim();
                if (newItem.isNotEmpty) {
                  setState(() {
                    items.add(newItem);
                    selectedItem = newItem;
                    itemController.text = newItem;
                  });
                  widget.onChanged?.call(selectedItem);
                  newItemController.clear();
                  menuFocusNode.unfocus();
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    itemController.removeListener(_syncSelectedItemWithController);
    if (widget.controller == null) {
      itemController.dispose();
    }
    newItemController.dispose();
    menuFocusNode.dispose();
    newItemFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<String>> baseEntries = [
      if (widget.allowNewItemAddition)
        DropdownMenuEntry(
          value: "new",
          label: "Add New Item",
          leadingIcon: const Icon(Icons.add),
        ),
      ...items.map((value) => DropdownMenuEntry(value: value, label: value)),
    ];

    return Align(
      alignment: Alignment.topCenter,
      child: FormField<String>(
        autovalidateMode: widget.autoValidateMode,
        validator: widget.validator,
        builder: (FormFieldState<String> field) {
          _formFieldState = field;

          // Sync FormField state value with selectedItem if needed
          if (selectedItem != field.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                field.didChange(selectedItem);
                _lastNotifiedValue = selectedItem;
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownMenu<String>(
                width: widget.dropdownWidth,
                controller: itemController,
                focusNode: menuFocusNode,
                label: widget.showLabelText ? Text(
                  widget.labelText,
                  style: const TextStyle(
                    color: Color(0xFF868B8F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.67,
                    letterSpacing: 0.20,
                  ),
                ) : null,
                textStyle: widget.labelTextStyle,
                hintText: widget.hintText,
                enableSearch: true,
                enableFilter: true,
                requestFocusOnTap: true,
                filterCallback: (entries, filter) {
                  final trimmed = filter.trim().toLowerCase();
                  final filtered = entries
                      .where((entry) =>
                          entry.value != "new" &&
                          entry.label.toLowerCase().contains(trimmed))
                      .toList();

                  if (trimmed.isEmpty) return entries;

                  if (filtered.isEmpty) {
                    return [
                      if (widget.allowNewItemAddition)
                        entries.firstWhere((e) => e.value == "new"),
                      const DropdownMenuEntry<String>(
                        value: "no-match",
                        label: "No match found",
                        enabled: false,
                      )
                    ];
                  }

                  return [
                    if (widget.allowNewItemAddition)
                      entries.firstWhere((e) => e.value == "new"),
                    ...filtered,
                  ];
                },
                inputDecorationTheme: InputDecorationTheme(
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  hintStyle: widget.hintTextStyle,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: field.hasError
                          ? Theme.of(context).colorScheme.error
                          : const Color(0xFFD8D9DD),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: field.hasError
                          ? Theme.of(context).colorScheme.error
                          : const Color(0xFFD8D9DD),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: field.hasError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).primaryColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                menuStyle: MenuStyle(
                  elevation: WidgetStateProperty.all(0),
                  maximumSize: WidgetStateProperty.all(Size.fromHeight(200)),
                  alignment: Alignment.bottomLeft,
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                onSelected: (item) {
                  if (item == "new") {
                    setState(() {
                      selectedItem = null;
                    });
                    menuFocusNode.unfocus();
                    showAddNewItemDialog();
                  } else {
                    setState(() {
                      selectedItem = item;
                      itemController.text = item!;
                    });
                    field.didChange(item);
                    menuFocusNode.unfocus();
                    widget.onChanged?.call(item);
                  }
                },
                leadingIcon: widget.leadingIcon ??
                    (widget.showLeadingIcon ? const Icon(Icons.search) : null),
                trailingIcon: (itemController.text.isNotEmpty)
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedItem = null;
                            itemController.clear();
                          });
                          field.didChange(null);
                          menuFocusNode.unfocus();
                          widget.onChanged?.call(null);
                        },
                        child: Icon(Icons.remove_circle_outline,
                            color: widget.clearIconColor),
                      )
                    : widget.trailingIcon,
                selectedTrailingIcon: widget.expandedTrailingIcon,
                dropdownMenuEntries: baseEntries,
                enabled: widget.enabled,
              ),
              SizedBox(
                height: 20,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: field.errorText != null
                      ? Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        )
                      : null, // empty space when no error
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
EOF

# ----------------------------
# 📝 Create progress_loader.dart
# ----------------------------
echo "📝 Creating progress_loader.dart..."
cat > lib/shared/widgets/progress_loader/progress_loader.dart << 'EOF'
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

enum LoaderType { circular, linear }

Widget showLoader({
  LoaderType type = LoaderType.circular,
  double? value,
  Color progressColor = AppColors.primaryColor,
  Color? backgroundColor,
  double strokeWidth = 2.0,
  Color? triangleColor,
  double triangleSize = 12,
}) {
  switch (type) {
    case LoaderType.linear:
      return LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? Colors.grey.shade300,
        color: progressColor,
      );
    case LoaderType.circular:
      return CircularProgressIndicator(
        value: value,
        color: progressColor,
        strokeWidth: strokeWidth,
      );
  }
}
EOF

# ----------------------------
# 📝 Create app_text_form_field.dart (Large file - Part 1)
# ----------------------------
echo "📝 Creating app_text_form_field.dart..."
cat > lib/shared/widgets/text_form_field/app_text_form_field.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/themes/app_colors.dart';
import '../../helpers/form_field_validators.dart';
import '../../helpers/input_formatter.dart';

enum FormFieldType {
  general,
  name,
  phone,
  email,
  password,
  confirmPassword,
  number,
  dob,
  readOnlyDisplay,
}

class AppTextFormField extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldType type;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? helperText;
  final TextStyle? helperStyle;
  final Widget? prefixIcon;
  final bool showIsoCodeOnly;
  final String isoCode;
  final Widget? suffixIcon;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function(PointerDownEvent)? onTapOutside;
  final String? Function(String?)? validator;
  final bool showCounter;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final TextCapitalization textCapitalization;

  const AppTextFormField({
    super.key,
    this.label,
    this.controller,
    this.initialValue,
    this.type = FormFieldType.general,
    this.hintText,
    this.hintStyle,
    this.helperText,
    this.helperStyle,
    this.prefixIcon,
    this.showIsoCodeOnly = false,
    this.isoCode = '880',
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.validator,
    this.showCounter = false,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconColor = AppColors.primaryColor,
    this.suffixIconColor = AppColors.primaryColor,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null && widget.initialValue != null) {
      throw FlutterError('TheTextFormField cannot have both controller and initialValue.');
    }

    if (widget.type == FormFieldType.readOnlyDisplay) {
      return TextFormField(
        controller: widget.controller,
        readOnly: true,
        style: const TextStyle(
          color: Color(0xFF20262E),
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1,
          letterSpacing: 0.50,
        ),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
          labelText: widget.label ?? '',
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF6C7B6F),
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0.50,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      );
    }

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      keyboardType: getKeyboardType(widget.type),
      textCapitalization: widget.textCapitalization,
      obscureText: (widget.type ==
              FormFieldType.password || widget.type == FormFieldType.confirmPassword)
          ? isObscured
          : widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      onChanged: (value) {
        widget.onChanged?.call(value);
        final trimmed = value.trim();
        if (widget.type == FormFieldType.phone) {
          final cleaned = trimmed.startsWith('0') ? trimmed.substring(1) : trimmed;
          if (cleaned != trimmed) {
            widget.controller?.text = cleaned;
            widget.controller?.selection = TextSelection.collapsed(offset: cleaned.length);
          }
          final isValidBDPhone = RegExp(r'^(1)[3-9]\d{8}$').hasMatch(cleaned);
          if (isValidBDPhone) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        }
      },
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside ?? (_) => FocusManager.instance.primaryFocus?.unfocus(),
      inputFormatters: getInputFormatters(widget.type),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator ?? (value) => validateField(value, widget.type),
      buildCounter: widget.showCounter
          ? (context, {required currentLength, required isFocused, maxLength}) => Text(
                '$currentLength/${maxLength ?? ""}',
                style: const TextStyle(
                  color: Color(0xFFA2A2A2),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              )
          : null,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0.50,
      ),
      decoration: InputDecoration(
        label: widget.label != null
            ? Text(
                widget.label!,
                style: const TextStyle(
                  color: Color(0xFF868B8F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.67,
                  letterSpacing: 0.20,
                ),
              )
            : null,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        helperText: widget.helperText,
        helperStyle: widget.helperStyle,
        prefixIcon: widget.prefixIcon ?? getDefaultPrefixIcon(widget.type, widget.prefixIconColor),
        suffixIcon: widget.type ==
                FormFieldType.password || widget.type == FormFieldType.confirmPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: Icon(
                    isObscured
                        ? Icons.visibility
                        : Icons.visibility_off, color: widget.suffixIconColor,
                  ),
                  onPressed: () => setState(() => isObscured = !isObscured),
                ),
              )
            : widget.suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Color(0xFFD8D9DD)),
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: AppColors.primaryColor),
        ),
        floatingLabelStyle: TextStyle(color: AppColors.primaryColor),
      ),
    );
  }

  TextInputType getKeyboardType(FormFieldType type) {
    switch (type) {
      case FormFieldType.name:
        return TextInputType.name;
      case FormFieldType.phone:
        return TextInputType.phone;
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  Widget? getDefaultPrefixIcon(FormFieldType type, Color? iconColor) {
    switch (type) {
      case FormFieldType.name:
        return Icon(Icons.person, color: iconColor);
      case FormFieldType.phone:
        return widget.showIsoCodeOnly
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Text(
                  widget.isoCode,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.29,
                    letterSpacing: 0.16,
                    color: Colors.black54,
                  ),
                ),
              )
            : Icon(Icons.phone, color: iconColor);
      case FormFieldType.email:
        return Icon(Icons.email, color: iconColor);
      case FormFieldType.password:
        return Icon(Icons.lock, color: iconColor);
      case FormFieldType.confirmPassword:
        return Icon(Icons.lock, color: iconColor);
      case FormFieldType.number:
        return Icon(Icons.numbers, color: iconColor);
      default:
        return null;
    }
  }
}
EOF

# ----------------------------
# 📝 Create app_spacer.dart
# ----------------------------
echo "📝 Creating app_spacer.dart..."
cat > lib/shared/widgets/spacer/app_spacer.dart << 'EOF'
import 'package:flutter/material.dart';

enum SpacerDirection { vertical, horizontal }

SizedBox addSpacer(double space, {SpacerDirection direction = SpacerDirection.vertical}) {
  return direction == SpacerDirection.vertical
      ? SizedBox(height: space)
      : SizedBox(width: space);
}
EOF

# ----------------------------
# 📝 Create app_snack_bar.dart
# ----------------------------
echo "📝 Creating app_snack_bar.dart..."
cat > lib/shared/widgets/snack_bar/app_snack_bar.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';

enum SnackBarStatus {
  success,
  warning,
  error,
  connected,
  disconnected,
  general
}

void showSnack({
  String? content = 'This functionality is under development',
  SnackBarStatus status = SnackBarStatus.warning,
  bool showCloseIcon = true,
  Duration duration = const Duration(seconds: 5),
  double bottomMargin = 50,
  SnackBarAction? action,
}) {
  final BuildContext? context = Get.context;
  final behavior = SnackBarBehavior.floating;

  if (context == null) return;

  Color backgroundColor;
  switch (status) {
    case SnackBarStatus.success:
      backgroundColor = AppColors.snackSuccessColor;
      break;
    case SnackBarStatus.warning:
      backgroundColor = AppColors.snackWarningColor;
      break;
    case SnackBarStatus.error:
      backgroundColor = AppColors.snackErrorColor;
      break;
    case SnackBarStatus.general:
      backgroundColor = AppColors.snackGeneralColor;
      break;
    case SnackBarStatus.connected:
      backgroundColor = Colors.green.shade100;
      break;
    case SnackBarStatus.disconnected:
      backgroundColor = Colors.blueGrey;
      break;
  }

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 0,
      content: Text(
        content!,
        style: TextStyle(
          color: status == SnackBarStatus.disconnected
              ? Colors.white
              : Colors.black
        ),
      ),
      backgroundColor: backgroundColor,
      behavior: behavior,
      margin: behavior == SnackBarBehavior.floating
          ? EdgeInsets.only(left: 16, right: 16, bottom: bottomMargin)
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      duration: action != null ? Duration.zero : duration,
      dismissDirection: DismissDirection.horizontal,
      showCloseIcon: showCloseIcon,
      closeIconColor: status == SnackBarStatus.disconnected
          ? Colors.white
          : Colors.black,
      action: action,
    ),
  );
}
EOF

# ----------------------------
# 📝 Create app_scaffold.dart
# ----------------------------
echo "📝 Creating app_scaffold.dart..."
cat > lib/shared/widgets/scaffold/app_scaffold.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final String message;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final double horizontalPadding;
  final double verticalPadding;

  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.message = 'Welcome!\nYour Flutter playground awaits... 🎯',
    this.horizontalPadding = 16,
    this.verticalPadding = 0,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: body ??
              Center(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
        ),
      ),
    );
  }
}
EOF

# ----------------------------
# 📝 Create text_controller_mixin.dart
# ----------------------------
echo "📝 Creating text_controller_mixin.dart..."
cat > lib/shared/mixins/text_controller_mixin.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin TextControllerMixin on GetxController {
  final Map<String, TextEditingController> textControllers = {};

  TextEditingController getTextCtrl(String key) {
    if (!textControllers.containsKey(key)) {
      textControllers[key] = TextEditingController();
    }
    return textControllers[key]!;
  }

  void disposeTextCtrl(String key) {
    if (textControllers.containsKey(key)) {
      textControllers[key]!.dispose();
      textControllers.remove(key);
    }
  }

  @override
  void onClose() {
    textControllers.forEach((_, ctrl) => ctrl.dispose());
    textControllers.clear();
    super.onClose();
  }
}
EOF

# ----------------------------
# 📝 Create pubspec.yaml
# ----------------------------
echo "📝 Creating pubspec.yaml..."
cat > pubspec.yaml << 'EOF'
name: your_app_name
description: "A new Flutter project."
publish_to: 'none'
version: 1.0.0+0

environment:
  sdk: ^3.0.0

# ----------------------------
# 📦 Dependencies
# ----------------------------
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  google_fonts: ^6.2.1
  get: ^4.6.6
  get_storage: ^2.1.1
  intl: ^0.19.0
  flutter_svg: ^2.0.10+1
  flutter_dotenv: ^5.1.0
  dio: ^5.7.0
  connectivity_plus: ^6.0.5
  logger: ^2.4.0

# ----------------------------
# 🧪 Dev Dependencies
# ----------------------------
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^4.0.0

# ----------------------------
# 🎯 Flutter Configuration
# ----------------------------
flutter:
  uses-material-design: true

  # ----------------------------
  # 🖼️ Asset folder for images, fonts, etc.
  # ----------------------------
  assets:
    - assets/images/
    - assets/fonts/
    - assets/envs/
EOF

# ----------------------------
# 📝 Create .env file
# ----------------------------
echo "📝 Creating .env file..."
cat > .env << 'EOF'
BASE_URL=https://api.example.com
EOF

# ----------------------------
# 🔧 Get Flutter dependencies
# ----------------------------
echo "🔧 Getting Flutter dependencies..."
flutter pub get

# ----------------------------
# ✅ Setup Complete
# ----------------------------
echo ""
echo "✅ Flutter project setup complete!"
echo ""
echo "📂 Project: $PROJECT_NAME"
echo "🎯 Next steps:"
echo "   1. cd $PROJECT_NAME"
echo "   2. Update .env file with your API base URL"
echo "   3. Update app title in lib/shared/widgets/material_app/material_app.dart"
echo "   4. Run: flutter run"
echo ""
echo "🚀 Happy coding!"
