/// One page of a list (`meta` of ApiResponse::paginated()).
class Paged<T> {
  const Paged({required this.items, required this.meta});

  final List<T> items;
  final PageMeta meta;

  /// More rows may follow (page mode: not on the last page; otherwise a full page came back).
  bool get hasMore {
    final current = meta.currentPage;
    final last = meta.lastPage;
    if (current != null && last != null) return current < last;
    return items.length >= meta.perPage;
  }
}

class PageMeta {
  const PageMeta({
    required this.perPage,
    this.currentPage,
    this.lastPage,
    this.total,
    this.nextCursor,
    this.unreadCount,
  });

  factory PageMeta.fromJson(Map<String, dynamic>? json, int fallbackPerPage) => PageMeta(
    perPage: (json?['per_page'] as num?)?.toInt() ?? fallbackPerPage,
    currentPage: (json?['current_page'] as num?)?.toInt(),
    lastPage: (json?['last_page'] as num?)?.toInt(),
    total: (json?['total'] as num?)?.toInt(),
    nextCursor: json?['next_cursor'] as String?,
    unreadCount: (json?['unread_count'] as num?)?.toInt(),
  );

  final int perPage;
  final int? currentPage;
  final int? lastPage;
  final int? total;
  final String? nextCursor;

  /// GET /notifications/mine only: unread in-app messages.
  final int? unreadCount;
}
