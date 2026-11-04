import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/billing/online_pay_text.dart';
import '../../../controllers/portal/portal_providers.dart';

/// "Pay online" on an invoice I owe: the server opens the charge for what I owe now (my co-pay when insured) and the
/// secure Tap page opens in the browser. Back in the app, the invoice is loaded again — the server books the money
/// only once Tap confirms it.
class PayOnlineButton extends ConsumerStatefulWidget {
  const PayOnlineButton({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  ConsumerState<PayOnlineButton> createState() => _PayOnlineButtonState();
}

class _PayOnlineButtonState extends ConsumerState<PayOnlineButton> {
  final _key = ApiClient.newIdempotencyKey();
  AppLifecycleListener? _lifecycle;

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final url = await ref.read(invoiceRepositoryProvider).startOnlinePayment(widget.invoiceId, idempotencyKey: _key);
    if (url == null || !await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (mounted) AppSnack.info(context, OnlinePayText.cannotOpen);
      return;
    }
    // Coming back from the browser: look again (once).
    _lifecycle?.dispose();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _lifecycle?.dispose();
        _lifecycle = null;
        if (!mounted) return;
        AppSnack.info(context, OnlinePayText.back);
        ref
          ..invalidate(invoiceDetailProvider(widget.invoiceId))
          ..invalidate(invoiceCoverageProvider(widget.invoiceId));
      },
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TapScale(
        child: AppButton(label: OnlinePayText.pay, icon: Icons.credit_card_rounded, onPressed: _pay, expand: true),
      ),
      const SizedBox(height: 4),
      Text(OnlinePayText.secure, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
