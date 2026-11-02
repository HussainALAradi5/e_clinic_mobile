part of 'order_providers.dart';

/// Which orders the work list shows (one chip each).
enum OrderKind {
  all('All', []),
  imaging('Imaging', [
    ClinicalOrderType.xray,
    ClinicalOrderType.ultrasound,
    ClinicalOrderType.ct,
    ClinicalOrderType.mri,
  ]),
  lab('Lab', [ClinicalOrderType.labTest]),
  ecg('ECG', [ClinicalOrderType.ecg]),
  referral('Referrals', [ClinicalOrderType.referral]);

  const OrderKind(this.label, this.types);

  final String label;
  final List<ClinicalOrderType> types;
}
