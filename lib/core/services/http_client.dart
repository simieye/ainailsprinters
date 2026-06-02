import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// 统一的 HTTP 客户端
/// 封装 Dio，提供认证拦截、重试、错误处理等功能
class HttpClient {
  HttpClient._();

  static final HttpClient instance = HttpClient._();

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  void initialize({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiConfig.simiaiBaseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Type': 'ai_nails_app',
        'X-Client-Version': '3.0.0',
      },
    ));

    // 认证拦截器
    _dio.interceptors.add(AuthInterceptor(_storage));

    // 日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[HTTP] $obj'),
    ));

    // 错误拦截器
    _dio.interceptors.add(ErrorInterceptor());

    // 重试拦截器
    _dio.interceptors.add(RetryInterceptor(_dio));
  }

  /// GET 请求
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? baseUrl,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: baseUrl != null
            ? Options(baseUrl: baseUrl)
            : null,
      );
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  /// POST 请求
  Future<ApiResponse> post(
    String path, {
    dynamic data,
    String? baseUrl,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: baseUrl != null
            ? Options(baseUrl: baseUrl)
            : null,
      );
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  /// PUT 请求
  Future<ApiResponse> put(
    String path, {
    dynamic data,
    String? baseUrl,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: baseUrl != null
            ? Options(baseUrl: baseUrl)
            : null,
      );
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  /// DELETE 请求
  Future<ApiResponse> delete(
    String path, {
    dynamic data,
    String? baseUrl,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        options: baseUrl != null
            ? Options(baseUrl: baseUrl)
            : null,
      );
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }

  /// 上传文件
  Future<ApiResponse> upload(
    String path, {
    required String filePath,
    String? baseUrl,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (extraFields != null) ...extraFields,
      });
      final response = await _dio.post(
        path,
        data: formData,
        options: baseUrl != null
            ? Options(baseUrl: baseUrl)
            : null,
      );
      return ApiResponse.fromDioResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromDioError(e);
    }
  }
}

/// 认证拦截器
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final tokenJson = await _storage.read(key: 'auth_token');
      if (tokenJson != null) {
        final token = jsonDecode(tokenJson) as Map<String, dynamic>;
        final accessToken = token['access_token'] as String?;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }
    } catch (_) {}

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 未授权 → 尝试刷新 Token
    if (err.response?.statusCode == 401) {
      try {
        final tokenJson = await _storage.read(key: 'auth_token');
        if (tokenJson != null) {
          final token = jsonDecode(tokenJson) as Map<String, dynamic>;
          final refreshToken = token['refresh_token'] as String?;
          if (refreshToken != null) {
            // 尝试刷新 Token
            final refreshResponse = await Dio().post(
              '${ApiConfig.authBaseUrl}${ApiConfig.authRefresh}',
              data: {'refresh_token': refreshToken},
            );

            if (refreshResponse.statusCode == 200) {
              final newToken = refreshResponse.data;
              await _storage.write(
                key: 'auth_token',
                value: jsonEncode(newToken),
              );

              // 重试原请求
              final opts = err.requestOptions;
              opts.headers['Authorization'] =
                  'Bearer ${newToken['access_token']}';
              final retryResponse = await Dio().fetch(opts);
              return handler.resolve(retryResponse);
            }
          }
        }
      } catch (_) {}
    }

    handler.next(err);
  }
}

/// 错误拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 统一错误格式
    final message = switch (err.type) {
      DioExceptionType.connectionTimeout => '连接超时',
      DioExceptionType.sendTimeout => '发送超时',
      DioExceptionType.receiveTimeout => '接收超时',
      DioExceptionType.connectionError => '网络连接失败',
      DioExceptionType.cancel => '请求已取消',
      _ => err.message ?? '未知错误',
    };

    err.message = message;
    handler.next(err);
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio _dio;

  RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    if (retryCount < ApiConfig.maxRetries && _shouldRetry(err)) {
      await Future.delayed(ApiConfig.retryDelay * (retryCount + 1));

      try {
        final opts = err.requestOptions;
        opts.extra['retry_count'] = retryCount + 1;
        final response = await _dio.fetch(opts);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// 统一 API 响应
class ApiResponse {
  final bool isSuccess;
  final int? statusCode;
  final dynamic data;
  final String? message;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.isSuccess,
    this.statusCode,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResponse.fromDioResponse(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return ApiResponse(
        isSuccess: response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300,
        statusCode: response.statusCode,
        data: body['data'] ?? body,
        message: body['message'] as String?,
        errors: body['errors'] as Map<String, dynamic>?,
      );
    }

    return ApiResponse(
      isSuccess: response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300,
      statusCode: response.statusCode,
      data: body,
    );
  }

  factory ApiResponse.fromDioError(DioException error) {
    final body = error.response?.data;
    String? message;
    Map<String, dynamic>? errors;

    if (body is Map<String, dynamic>) {
      message = body['message'] as String?;
      errors = body['errors'] as Map<String, dynamic>?;
    }

    return ApiResponse(
      isSuccess: false,
      statusCode: error.response?.statusCode,
      message: message ?? error.message ?? '请求失败',
      errors: errors,
    );
  }

  /// 获取 data 作为 Map
  Map<String, dynamic> get dataAsMap =>
      data is Map<String, dynamic> ? data as Map<String, dynamic> : {};

  /// 获取 data 作为 List
  List<dynamic> get dataAsList =>
      data is List ? data as List<dynamic> : [];
}
