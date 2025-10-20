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
