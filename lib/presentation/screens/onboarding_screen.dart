import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/adhan_packs.dart';
import '../../core/enums/calculation_method.dart';
import '../../core/enums/madhab.dart';
import '../../data/services/notification_service.dart';
import '../providers/location_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const Color _bgTop = Color(0xFF02030A);
  static const Color _bgMid = Color(0xFF071330);
  static const Color _bgBottom = Color(0xFF02030A);
  static const Color _premiumGold = Color(0xFFFFD98F);
  static const Color _premiumGoldBright = Color(0xFFFFE6A8);
  static const Color _premiumNavy = Color(0xFF030612);
  static const Color _primaryText = Color(0xFFEFF3FF);
  static const Color _secondaryText = Color(0xFFA9B3CB);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[_bgTop, _bgMid, _bgBottom],
            stops: <double>[0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                AppLocalizations.of(context)!.welcome,
                style: GoogleFonts.cinzel(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: _premiumGoldBright,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: _premiumGold.withValues(alpha: 0.3),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.welcomeSubtitle,
                style: GoogleFonts.manrope(
                  color: _secondaryText,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.stepLocation,
                      style: GoogleFonts.cinzel(
                        color: _premiumGoldBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _premiumGold,
                        foregroundColor: _premiumNavy,
                        disabledBackgroundColor: _premiumGold.withValues(
                          alpha: 0.35,
                        ),
                        disabledForegroundColor: _premiumNavy.withValues(
                          alpha: 0.65,
                        ),
                        minimumSize: const Size(double.infinity, 62),
                        textStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: () async {
                        await context
                            .read<LocationProvider>()
                            .refreshCurrentLocation();
                      },
                      icon: const Icon(Icons.location_searching),
                      label: Text(
                        locationProvider.location == null
                            ? AppLocalizations.of(context)!.useCurrentLocation
                            : locationProvider.location!.cityName,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _premiumGold,
                        minimumSize: const Size(double.infinity, 56),
                        textStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        side: BorderSide(
                          color: _premiumGold.withValues(alpha: 0.6),
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _openLocationPicker(context),
                      icon: const Icon(Icons.search),
                      label: Text(AppLocalizations.of(context)!.enterLocation),
                    ),
                    if (locationProvider.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        locationProvider.errorMessage!,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFFB6AE),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.stepCalculationMethod,
                      style: GoogleFonts.cinzel(
                        color: _premiumGoldBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CalculationMethod>(
                      initialValue: settings.calculationMethod,
                      style: GoogleFonts.manrope(
                        color: _primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      iconEnabledColor: _premiumGold,
                      dropdownColor: const Color(0xFF151E31),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: CalculationMethod.values
                          .map(
                            (m) => DropdownMenuItem<CalculationMethod>(
                              value: m,
                              child: Text(_methodLabel(m, context)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) {
                          return;
                        }
                        await settingsProvider.saveSettings(
                          settings.copyWith(calculationMethod: value),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppLocalizations.of(context)!.stepAsrMadhab,
                      style: GoogleFonts.cinzel(
                        color: _premiumGoldBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<Madhab>(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? _premiumGold
                              : Colors.transparent,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) => states.contains(WidgetState.selected)
                              ? _premiumNavy
                              : _primaryText,
                        ),
                        textStyle: WidgetStatePropertyAll<TextStyle>(
                          GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        side: WidgetStatePropertyAll<BorderSide>(
                          BorderSide(
                            color: _premiumGold.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      segments: [
                        ButtonSegment<Madhab>(
                          value: Madhab.nonHanafi,
                          label: Text(AppLocalizations.of(context)!.madhabNonHanafi),
                        ),
                        ButtonSegment<Madhab>(
                          value: Madhab.hanafi,
                          label: Text(AppLocalizations.of(context)!.madhabHanafi),
                        ),
                      ],
                      selected: {settings.madhab},
                      onSelectionChanged: (selection) async {
                        await settingsProvider.saveSettings(
                          settings.copyWith(madhab: selection.first),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppLocalizations.of(context)!.stepFullAdhanPack,
                      style: GoogleFonts.cinzel(
                        color: _premiumGoldBright,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: settings.selectedAdhanPackId,
                      style: GoogleFonts.manrope(
                        color: _primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      iconEnabledColor: _premiumGold,
                      dropdownColor: const Color(0xFF151E31),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: AdhanPacks.all
                          .map(
                            (pack) => DropdownMenuItem<String>(
                              value: pack.id,
                              child: Text(pack.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) {
                          return;
                        }
                        await settingsProvider.saveSettings(
                          settings.copyWith(selectedAdhanPackId: value),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.adhanPackNote,
                      style: GoogleFonts.manrope(
                        color: _secondaryText,
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _premiumGold,
                  foregroundColor: _premiumNavy,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.4),
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  textStyle: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: locationProvider.location == null
                    ? null
                    : () async {
                        try {
                          final prayerProvider = context.read<PrayerProvider>();
                          final settingsSnapshot = context
                              .read<SettingsProvider>()
                              .settings;
                          final location = locationProvider.location;
                          if (location != null) {
                            await prayerProvider.recalculateForLocation(
                              location,
                            );
                          } else {
                            await prayerProvider.loadPrayerTimes();
                          }
                          prayerProvider.startCountdown();
                          final times = prayerProvider.prayerTimes;
                          if (times != null) {
                            try {
                              await NotificationService()
                                  .scheduleAllPrayerNotifications(
                                    times,
                                    settingsSnapshot,
                                  );
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!.notificationsCouldNotBeScheduled(error.toString()),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.couldNotContinue(error.toString()),
                              ),
                            ),
                          );
                        }
                      },
                child: Text(AppLocalizations.of(context)!.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _methodLabel(CalculationMethod method, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case CalculationMethod.isna:
        return l10n.methodIsna;
      case CalculationMethod.muslimWorldLeague:
        return l10n.methodMuslimWorldLeague;
      case CalculationMethod.turkeyDiyanet:
        return l10n.methodTurkeyDiyanet;
      case CalculationMethod.egyptian:
        return l10n.methodEgyptian;
      case CalculationMethod.karachi:
        return l10n.methodKarachi;
      case CalculationMethod.ummAlQura:
        return l10n.methodUmmAlQura;
      case CalculationMethod.dubai:
        return l10n.methodDubai;
      case CalculationMethod.singapore:
        return l10n.methodSingapore;
      case CalculationMethod.tehran:
        return l10n.methodTehran;
    }
  }

  Future<void> _openLocationPicker(BuildContext context) async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF02030A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Consumer<LocationProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                height: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enterLocation,
                      style: GoogleFonts.cinzel(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _premiumGoldBright,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      style: GoogleFonts.manrope(color: _primaryText),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.cityOrAddress,
                        hintStyle: GoogleFonts.manrope(color: _secondaryText),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: _premiumGold),
                          onPressed: () async {
                            await provider.searchManualLocations(
                              controller.text.trim(),
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) async {
                        await provider.searchManualLocations(value.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    if (provider.isLoading)
                      const LinearProgressIndicator(minHeight: 3),
                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        provider.errorMessage!,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFFB6AE),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        itemCount: provider.manualCandidates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = provider.manualCandidates[index];
                          final subtitle =
                              '${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}';
                          return ListTile(
                            tileColor: Colors.white.withValues(alpha: 0.06),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(
                              item.cityName,
                              style: GoogleFonts.manrope(color: _primaryText),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: GoogleFonts.manrope(color: _secondaryText),
                            ),
                            trailing: Text(
                              item.countryCode,
                              style: GoogleFonts.manrope(
                                color: _premiumGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () async {
                              await provider.setManualLocation(item);
                              if (!sheetContext.mounted) {
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111623).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFD98F).withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFFFFD98F).withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: -6,
          ),
        ],
      ),
      child: child,
    );
  }
}
