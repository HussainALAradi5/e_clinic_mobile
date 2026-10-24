/// Patient app routes.
abstract final class PortalPaths {
  static const home = '/';
  static const visits = '/appointments';
  static const book = '/appointments/new';
  static const treatments = '/treatments';
  static const results = '/results';
  static const prescriptions = '/prescriptions';
  static const invoices = '/invoices';
  static const messages = '/notifications';
  static const profile = '/profile';

  /// Where a message leads, by its related record.
  static String? forRelated(String? relatedType) => switch (relatedType) {
    'appointment' => visits,
    'treatment' => treatments,
    'clinical_order' => results,
    'prescription' => prescriptions,
    'invoice' || 'payment' => invoices,
    _ => null,
  };
}
