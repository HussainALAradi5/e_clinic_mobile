import 'package:flutter/material.dart';

/// Pine header with the brand mark and a white sheet for the form — the sign-in screens' frame.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.child, this.onBack});

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final headerColor = dark ? const Color(0xFF052A27) : const Color(0xFF0B5D57);
    return Scaffold(
      backgroundColor: headerColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 48,
                            child: onBack == null
                                ? const BrandMark()
                                : IconButton(
                                    tooltip: 'Back',
                                    onPressed: onBack,
                                    color: Colors.white,
                                    icon: const Icon(Icons.arrow_back_rounded),
                                  ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFFC6F0E8)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + MediaQuery.paddingOf(context).bottom),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLowest,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
