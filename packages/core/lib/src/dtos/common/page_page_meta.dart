part of 'page.dart';

class PageMeta {
  const PageMeta({
    required this.perPage,
    this.currentPage,
    this.lastPage,
    this.total,
    this.nextCursor,
    this.unreadCount,
    this.extra = const {},
  });

  factory PageMeta.fromJson(Map<String, dynamic>? json, int fallbackPerPage) => PageMeta(
    perPage: (json?['per_page'] as num?)?.toInt() ?? fallbackPerPage,
    currentPage: (json?['current_page'] as num?)?.toInt(),
    lastPage: (json?['last_page'] as num?)?.toInt(),
    total: (json?['total'] as num?)?.toInt(),
    nextCursor: json?['next_cursor'] as String?,
    unreadCount: (json?['unread_count'] as num?)?.toInt(),
    extra: json ?? const {},
  );

  final int perPage;
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final String? nextCursor;

  /// GET /notifications/mine only: unread in-app messages.
  final int? unreadCount;

  /// The whole meta object, for endpoint-specific values (e.g. the wallet's `balance`).
  final Map<String, dynamic> extra;
}
