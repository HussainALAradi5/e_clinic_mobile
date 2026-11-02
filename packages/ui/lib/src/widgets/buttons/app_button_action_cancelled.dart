part of 'app_button.dart';

/// Thrown by an action that stopped on purpose (e.g. the form is invalid): the button resets without a message.
class ActionCancelled implements Exception {
  const ActionCancelled();
}
