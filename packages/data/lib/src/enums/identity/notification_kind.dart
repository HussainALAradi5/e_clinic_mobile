/// What a message is about, so it can look and sound different: worked out on the phone from the message's
/// template (see notificationKindOf). Colours and icons are the UI's; the sound is a bundled Android resource
/// (`res/raw/<sound>.wav`, made by tools/make_notification_sounds.py), one per kind; so is its image
/// (`res/drawable-nodpi/<sound>.png`, made by tools/make_icons.py).
enum NotificationKind {
  visit('Visits', 'notify_visit'),
  treatment('Treatments', 'notify_treatment'),
  result('Results & orders', 'notify_result'),
  pharmacy('Prescriptions & pharmacy', 'notify_pharmacy'),
  billing('Billing & approvals', 'notify_billing'),
  hr('Leave, attendance & payroll', 'notify_hr'),
  chat('Chat', 'notify_chat'),
  support('Support tickets', 'notify_support'),
  urgent('Urgent', 'notify_urgent'),
  files('Exports & imports', 'notify_files'),
  system('Other', 'notify_system');

  const NotificationKind(this.label, this.sound);

  /// The name of its notification channel on the phone (people can mute one kind in the phone's settings).
  final String label;

  /// Android raw resource of its sound.
  final String sound;
}
