/// Patient routes (the patient's part of the app).
abstract final class PortalPaths {
  static const home = '/home';
  static const visits = '/appointments';
  static const book = '/appointments/new';
  static const treatments = '/treatments';
  static const results = '/results';
  static const prescriptions = '/prescriptions';
  static const sickLeaves = '/sick-leaves';
  static const invoices = '/invoices';
  static const messages = '/notifications';
  static const profile = '/profile';

  static const _roots = [home, visits, treatments, results, prescriptions, sickLeaves, invoices, messages, profile];

  /// The path is part of the patient area.
  static bool owns(String path) => _roots.any((root) => path == root || path.startsWith('$root/'));

  /// Where a message leads, by its related record.
  static String? forRelated(String? relatedType) => switch (relatedType) {
    'appointment' => visits,
    'treatment' => treatments,
    'clinical_order' => results,
    'prescription' => prescriptions,
    'sick_leave' => sickLeaves,
    'invoice' || 'payment' => invoices,
    _ => null,
  };
}
