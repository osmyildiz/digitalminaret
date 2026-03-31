import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/services/donation_service.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/premium_settings_widgets.dart';

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  final DonationService _donationService = DonationService();
  static const bool _screenshotMode = false;
  bool _loading = true;
  bool _buying = false;
  List<DonationPackage> _packages = const [];
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    if (_screenshotMode) {
      _loading = false;
      return;
    }
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _debugInfo = '';
    });
    final packages = await _donationService.loadTipPackages();
    final debugInfo = await _donationService.collectDebugReport();
    if (!mounted) {
      return;
    }
    setState(() {
      _packages = packages;
      _debugInfo = debugInfo;
      _loading = false;
    });
  }

  Future<void> _buy(DonationPackage package) async {
    setState(() => _buying = true);
    final success = await _donationService.purchase(package);
    if (!mounted) {
      return;
    }
    setState(() => _buying = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.purchaseDidNotComplete)),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.thankYou),
        content: Text(
          AppLocalizations.of(ctx)!.thankYouDonateMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.close),
          ),
        ],
      ),
    );
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFFE6A8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.supportTheApp,
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFE6A8),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.donateDescription,
                style: GoogleFonts.manrope(
                  color: const Color(0xB3D2DAF3),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              if (_screenshotMode) ...[
                _MockTipCard(
                  title: AppLocalizations.of(context)!.smallTip,
                  description: 'One-time support level: \$0.99',
                  priceLabel: '\$0.99',
                ),
                const SizedBox(height: 10),
                _MockTipCard(
                  title: AppLocalizations.of(context)!.mediumTip,
                  description: 'One-time support level: \$4.99',
                  priceLabel: '\$4.99',
                ),
                const SizedBox(height: 10),
                _MockTipCard(
                  title: AppLocalizations.of(context)!.largeTip,
                  description: 'One-time support level: \$99.99',
                  priceLabel: '\$99.99',
                ),
              ] else if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_packages.isEmpty)
                _UnavailableCard(
                  onRetry: _loadPackages,
                  debugInfo: _debugInfo,
                )
              else
                ..._packages.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TipCard(
                      package: p,
                      buying: _buying,
                      onTap: () => _buy(p),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockTipCard extends StatelessWidget {
  const _MockTipCard({
    required this.title,
    required this.description,
    required this.priceLabel,
  });

  final String title;
  final String description;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return PremiumSettingsCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: const Color(0xFFFFD98F).withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Color(0xFFFFD98F),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    color: const Color(0xB3D2DAF3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            priceLabel,
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFD98F),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.package,
    required this.buying,
    required this.onTap,
  });

  final DonationPackage package;
  final bool buying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: buying ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: PremiumSettingsCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: const Color(0xFFFFD98F).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: Color(0xFFFFD98F),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFEFF3FF),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      package.description,
                      style: GoogleFonts.manrope(
                        color: const Color(0xB3D2DAF3),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                package.priceLabel,
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFFFD98F),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  const _UnavailableCard({required this.onRetry, required this.debugInfo});

  final Future<void> Function() onRetry;
  final String debugInfo;

  @override
  Widget build(BuildContext context) {
    return PremiumSettingsCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.donationOptionsUnavailable,
            style: GoogleFonts.manrope(
              color: const Color(0xFFEFF3FF),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.donationOptionsSetup,
            style: GoogleFonts.manrope(
              color: const Color(0xB3D2DAF3),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          if (debugInfo.isNotEmpty) ...[
            SelectableText(
              debugInfo,
              style: GoogleFonts.robotoMono(
                color: const Color(0xB3D2DAF3),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color(0xFFFFD98F).withValues(alpha: 0.5),
              ),
              foregroundColor: const Color(0xFFFFD98F),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
