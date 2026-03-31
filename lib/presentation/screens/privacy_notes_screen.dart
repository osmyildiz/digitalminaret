import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/premium_settings_widgets.dart';

class PrivacyNotesScreen extends StatelessWidget {
  const PrivacyNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xFF02030A), Color(0xFF071330), Color(0xFF02030A)],
      stops: <double>[0, 0.55, 1],
    );
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFFE6A8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.privacyNotes,
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFE6A8),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _NoteItem(
                title: AppLocalizations.of(context)!.privacyNoAccountRequired,
                body: AppLocalizations.of(context)!.privacyNoAccountBody,
              ),
              _NoteItem(
                title: AppLocalizations.of(context)!.privacyLocationOnDevice,
                body: AppLocalizations.of(context)!.privacyLocationBody,
              ),
              _NoteItem(
                title: AppLocalizations.of(context)!.privacyNoAds,
                body: AppLocalizations.of(context)!.privacyNoAdsBody,
              ),
              _NoteItem(
                title: AppLocalizations.of(context)!.privacyNotificationsLocal,
                body: AppLocalizations.of(context)!.privacyNotificationsBody,
              ),
              _NoteItem(
                title: AppLocalizations.of(context)!.privacyFeedbackOptIn,
                body: AppLocalizations.of(context)!.privacyFeedbackBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  const _NoteItem({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return PremiumSettingsCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              color: const Color(0xFFEFF3FF),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.manrope(
              color: const Color(0xB3D2DAF3),
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
