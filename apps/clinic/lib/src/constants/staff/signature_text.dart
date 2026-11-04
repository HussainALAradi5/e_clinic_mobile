/// Wording of the signature screen (staff).
abstract final class SignatureText {
  static const title = 'My signature';
  static const linkSubtitle = 'Printed on the documents you issue';
  static const intro = 'Printed on the documents you issue — sick leaves, results, prescriptions, certificates.';
  static const current = 'Your signature';
  static const none = 'No signature yet.';
  static const draw = 'Sign in the box with your finger or a pen.';
  static const pad = 'Signature pad';
  static const clear = 'Clear';
  static const save = 'Save signature';
  static const upload = 'Upload a photo of it';
  static const remove = 'Remove';
  static const saved = 'Signature saved.';
  static const removed = 'Signature removed.';
  static const empty = 'Sign in the box first.';
  static const tooBig = 'The photo is over 1 MB. Try a smaller one.';

  /// Largest image the server accepts.
  static const maxBytes = 1024 * 1024;
}
