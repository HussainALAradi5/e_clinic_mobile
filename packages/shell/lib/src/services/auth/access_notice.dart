import 'package:e_clinic_ui/ui.dart';

import '../../constants/auth/access_notice_text.dart';

/// "Unauthorized access" messages for refused screens and ended sessions (shown without a screen's context).
abstract final class AccessNotice {
  static void signInNeeded() => AppSnack.notice(AccessNoticeText.title, AccessNoticeText.signInNeeded);

  static void sessionEnded() => AppSnack.notice(AccessNoticeText.title, AccessNoticeText.sessionEnded);

  static void noAccess() => AppSnack.notice(AccessNoticeText.title, AccessNoticeText.noAccess);
}
