part of 'order_providers.dart';

/// Which orders the work list shows (one chip each).
enum OrderKind {
  all(OrderActionText.all, []),
  imaging(OrderActionText.imaging, [
    ClinicalOrderType.xray,
    ClinicalOrderType.ultrasound,
    ClinicalOrderType.ct,
    ClinicalOrderType.mri,
  ]),
  lab(OrderActionText.lab, [ClinicalOrderType.labTest]),
  ecg(OrderActionText.ecg, [ClinicalOrderType.ecg]),
  referral(OrderActionText.referrals, [ClinicalOrderType.referral]);

  const OrderKind(this.label, this.types);

  final String label;
  final List<ClinicalOrderType> types;
}
