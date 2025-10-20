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
