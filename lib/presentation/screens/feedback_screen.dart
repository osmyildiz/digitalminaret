import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/premium_settings_widgets.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final TextEditingController _subjectController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subjectInitialized) {
      _subjectController = TextEditingController(
        text: AppLocalizations.of(context)!.feedbackSubject,
      );
      _subjectInitialized = true;
    }
  }

  bool _subjectInitialized = false;

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    final subject = _subjectController.text.trim().isEmpty
        ? AppLocalizations.of(context)!.feedbackSubject
        : _subjectController.text.trim();
    final body = _messageController.text.trim();

    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.feedbackEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.mailCouldNotBeOpened)),
      );
    }
  }

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
                    icon: const Icon(Icons.close, color: Color(0xFFFFE6A8)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.sendFeedback,
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFE6A8),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PremiumSettingsCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _subjectController,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFEFF3FF),
                      ),
                      decoration: _inputDecoration(AppLocalizations.of(context)!.subject),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFEFF3FF),
                      ),
                      maxLines: 8,
                      decoration: _inputDecoration(AppLocalizations.of(context)!.yourFeedback),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _sendFeedback,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD98F),
                        foregroundColor: const Color(0xFF111623),
                        minimumSize: const Size(double.infinity, 52),
                        textStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.send_rounded),
                      label: Text(AppLocalizations.of(context)!.openMailApp),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.feedbackHint,
                      style: GoogleFonts.manrope(
                        color: const Color(0xB3D2DAF3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(color: const Color(0xB3D2DAF3)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: const Color(0xFFFFD98F).withValues(alpha: 0.30),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFFD98F), width: 1.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
