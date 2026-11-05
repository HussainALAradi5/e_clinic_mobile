part of 'signature_pad.dart';

/// Holds what was drawn on a [SignaturePad]: clear it, check it is not empty, export it as PNG.
class SignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  Size _size = Size.zero;

  bool get isEmpty => _strokes.every((s) => s.length < 2);

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  void _start(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void _extend(Offset point) {
    _strokes.last.add(point);
    notifyListeners();
  }

  /// The signature as a transparent PNG at the device's pixel ratio.
  Future<Uint8List?> toPng(double pixelRatio) async {
    if (isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    _SignaturePainter(this).paint(canvas, _size);
    final image = await recorder.endRecording().toImage(
      (_size.width * pixelRatio).ceil(),
      (_size.height * pixelRatio).ceil(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }
}
