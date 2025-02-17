import 'package:flutter/foundation.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final String? nextCursor;
  final bool hasMore;
  final Map<String, dynamic>? meta;
  final int currentPage;
  final int lastPage;
  final int total;
  final Map<String, dynamic>? pagination;

  PaginatedResponse({
    required this.data,
    this.nextCursor,
    this.hasMore = true,
    this.meta,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      debugPrint('PaginatedResponse: Parsing JSON response');
      debugPrint('Raw JSON structure: ${json.keys.join(', ')}');

      // Handle API response structure
      Map<String, dynamic>? metaData = json['meta'] as Map<String, dynamic>?;
      List<dynamic> dataList = [];
      Map<String, dynamic>? paginationData;

      if (json.containsKey('data')) {
        var rawData = json['data'];
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          // Handle nested data structure
          debugPrint('Found nested data structure');
          dataList = rawData['data'] as List;
          paginationData = rawData;
        } else if (rawData is List) {
          // Handle flat data structure
          debugPrint('Found flat data structure');
          dataList = rawData;
          // Check if pagination info is in the parent object
          if (json.containsKey('pagination')) {
            paginationData = json['pagination'] as Map<String, dynamic>;
          }
        }
      }

      debugPrint('Found ${dataList.length} items in data list');

      // Parse items with error handling
      final parsedData = dataList.map((item) {
        try {
          if (item is! Map<String, dynamic>) {
            debugPrint('Converting item to Map<String, dynamic>');
            item = Map<String, dynamic>.from(item as Map);
          }
          return fromJson(item);
        } catch (e) {
          debugPrint('Error parsing item: $e');
          debugPrint('Problematic item: $item');
          return null;
        }
      }).where((item) => item != null).cast<T>().toList();

      debugPrint('Successfully parsed ${parsedData.length} items');

      // Get pagination info from the API response
      String? nextCursor;
      int currentPage = 1;
      int lastPage = 1;
      int total = 0;

      if (paginationData != null) {
        nextCursor = paginationData['next_page_url']?.toString();
        currentPage = paginationData['current_page'] as int? ?? 1;
        lastPage = paginationData['last_page'] as int? ?? 1;
        total = paginationData['total'] as int? ?? 0;

        debugPrint('Pagination info from API:');
        debugPrint('- Current page: $currentPage');
        debugPrint('- Last page: $lastPage');
        debugPrint('- Total items: $total');
        debugPrint('- Next cursor: $nextCursor');
      }

      // Determine if there are more pages based on current_page and last_page
      bool hasMore = currentPage < lastPage;
      debugPrint('Has more pages: $hasMore (current: $currentPage, last: $lastPage)');

      return PaginatedResponse(
        data: parsedData,
        nextCursor: nextCursor,
        hasMore: hasMore,
        meta: metaData,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
        pagination: paginationData,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing paginated response: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Raw JSON: $json');
      return PaginatedResponse(
        data: [],
        hasMore: false,
      );
    }
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) {
    return {
      'data': data.map((item) => toJson(item)).toList(),
      'next_cursor': nextCursor,
      'has_more': hasMore,
      'meta': meta,
      'current_page': currentPage,
      'last_page': lastPage,
      'total': total,
      'pagination': pagination,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse(items: ${data.length}, currentPage: $currentPage, lastPage: $lastPage, total: $total, hasMore: $hasMore)';
  }
}
