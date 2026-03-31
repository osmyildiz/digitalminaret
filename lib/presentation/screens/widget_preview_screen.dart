import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class WidgetPreviewScreen extends StatelessWidget {
  const WidgetPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF030612),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l.widgetSetupTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SetupCard(
            title: l.widgetLiveTitle,
            body: l.widgetLiveBody,
          ),
          const SizedBox(height: 12),
          _SetupCard(
            title: l.widgetIosTitle,
            body: l.widgetIosBody,
          ),
          const SizedBox(height: 12),
          _SetupCard(
            title: l.widgetAndroidTitle,
            body: l.widgetAndroidBody,
          ),
          const SizedBox(height: 12),
          _SetupCard(
            title: l.widgetTypographyTitle,
            body: l.widgetTypographyBody,
          ),
        ],
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD98F),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
