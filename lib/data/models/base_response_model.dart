class BaseResponse<T> {
  final String status;
  final int code;
  final String message;
  final T? data;
  final String? token;

  BaseResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
    this.token,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic json)? fromJsonT,
  ) {
    return BaseResponse<T>(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic>? Function(T?)? toJsonT) {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data) : data,
      'token': token,
    };
  }

  bool get isSuccess => status == 'Success' && code == 200;
  bool get isError => status == 'Error' || code != 200;
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'totalItems': totalItems,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
