class ApiResponse<T> {
  final Meta meta;
  final T data;

  ApiResponse({
    required this.meta,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse(
      meta: Meta.fromJson(json['meta']),
      data: fromJsonT(json['data']),
    );
  }
}

class Meta {
  final int code;
  final String status;
  final String message;

  Meta({
    required this.code,
    required this.status,
    required this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        code: json['code'],
        status: json['status'],
        message: json['message'],
      );
}

class PaginatedData<T> {
  final List<T> data;
  final int currentPage;
  final String firstPageUrl;
  final int lastPage;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int total;

  PaginatedData({
    required this.data,
    required this.currentPage,
    required this.firstPageUrl,
    required this.lastPage,
    required this.lastPageUrl,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.total,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedData(
      data: (json['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'],
      firstPageUrl: json['first_page_url'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      total: json['total'],
    );
  }
}
