/// Wording of the document widgets (PDF buttons).
abstract final class DocumentText {
  static const open = 'Open PDF';
  static const download = 'Download';
  static const noViewer = 'No app on this phone can open the PDF.';
  static String saved(String code, String fileName, String size) => '$code · $fileName · $size';
}
