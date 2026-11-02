part 'page_page_meta.dart';

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
