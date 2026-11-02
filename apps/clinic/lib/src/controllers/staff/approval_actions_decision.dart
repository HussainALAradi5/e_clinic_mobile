part of 'approval_actions.dart';

/// One request waiting for a decision: what the approve confirmation says, and the two server calls.
/// The buttons ask (confirm / reason) before they lock, so the spinner covers only the call.
class Decision {
  const Decision({
    required this.approveConfirm,
    required this.approve,
    required this.approved,
    this.rejectTitle = 'Reject this request?',
    this.reject,
  });

  final ConfirmConfig approveConfirm;

  /// May ask a follow-up question when the server needs one (leave over booked days).
  final Future<void> Function(BuildContext context) approve;
  final String approved;
  final String rejectTitle;

  /// Null where there is nothing to reject (unapproved overtime is simply not paid).
  final Future<Object?> Function(String reason)? reject;
}
