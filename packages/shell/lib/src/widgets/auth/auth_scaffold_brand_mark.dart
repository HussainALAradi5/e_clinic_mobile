part of 'auth_scaffold.dart';

/// The e-Clinic mark: a rounded mint tile with a cross, and the name.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: const Color(0xFFD3EFE9), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add_rounded, color: Color(0xFF0B5D57), size: 30),
      ),
      const SizedBox(width: 12),
      Text(
        'e-Clinic',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
