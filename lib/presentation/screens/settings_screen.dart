import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/adhan_packs.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/supported_locales.dart';
import '../../core/enums/calculation_method.dart';
import '../../core/enums/madhab.dart';
import '../../core/enums/prayer_alert_mode.dart';
import '../../core/enums/prayer_type.dart';
import '../../data/models/prayer_times_model.dart';
import '../../data/models/settings_model.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/adhan_pack_download_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/widget_service.dart';
import '../providers/location_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/premium_settings_widgets.dart';
import '../../l10n/app_localizations.dart';
import 'donate_screen.dart';
import 'feedback_screen.dart';
import 'privacy_notes_screen.dart';
import 'widget_preview_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.storageService,
    this.audioService,
    this.adhanPackDownloadService,
    this.urlLauncher,
    this.scheduleNotifications,
    this.initializeNotifications,
    this.requestNotificationPermission,
    this.runBootTasks = true,
  });

  final StorageService? storageService;
  final AudioService? audioService;
  final AdhanPackDownloadGateway? adhanPackDownloadService;
  final Future<bool> Function(Uri uri)? urlLauncher;
  final Future<void> Function(PrayerTimesModel times, SettingsModel settings)?
  scheduleNotifications;
  final Future<void> Function()? initializeNotifications;
  final Future<bool> Function()? requestNotificationPermission;
  final bool runBootTasks;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final StorageService _storageService;
  late final AudioService _audioService;
  late final AdhanPackDownloadGateway _packDownloadService;
  int _appOpenCount = 0;
  bool _hasRated = false;
  PrayerType? _previewPrayerType;

  static const Color _snackBg = Color(0xFF112544);
  static const Color _snackFg = Color(0xFFF5F8FF);

  SnackBar _buildSnack(String message) {
    return SnackBar(
      backgroundColor: _snackBg,
      behavior: SnackBarBehavior.floating,
      content: Text(
        message,
        style: const TextStyle(color: _snackFg, fontWeight: FontWeight.w600),
      ),
    );
  }

  bool get _showRatePrompt => AppConstants.shouldShowRatePrompt(
    appOpenCount: _appOpenCount,
    hasRated: _hasRated,
  );

  @override
  void initState() {
    super.initState();
    _storageService = widget.storageService ?? StorageService();
    _audioService = widget.audioService ?? AudioService();
    _packDownloadService =
        widget.adhanPackDownloadService ?? AdhanPackDownloadService();
    AudioService.isPlaying.addListener(_onPlayingChanged);
    if (widget.runBootTasks) {
      _loadEngagement();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureSunriseNotificationsDisabled();
      });
    }
  }

  void _onPlayingChanged() {
    if (!mounted) {
      return;
    }
    if (!AudioService.isPlaying.value && _previewPrayerType != null) {
      setState(() {
        _previewPrayerType = null;
      });
      return;
    }
    setState(() {});
  }

  Future<void> _ensureSunriseNotificationsDisabled() async {
    if (!mounted) {
      return;
    }
    final provider = context.read<SettingsProvider>();
    final settings = provider.settings;
    final currentMode = settings.prayerAlertModes[PrayerType.sunrise];
    final currentlyEnabled =
        settings.enabledPrayers[PrayerType.sunrise] ?? true;
    if (currentMode == PrayerAlertMode.off && !currentlyEnabled) {
      return;
    }

    final updatedModes = Map<PrayerType, PrayerAlertMode>.from(
      settings.prayerAlertModes,
    );
    updatedModes[PrayerType.sunrise] = PrayerAlertMode.off;
    final updatedEnabled = Map<PrayerType, bool>.from(settings.enabledPrayers);
    updatedEnabled[PrayerType.sunrise] = false;

    await provider.saveSettings(
      settings.copyWith(
        prayerAlertModes: updatedModes,
        enabledPrayers: updatedEnabled,
      ),
    );
    await _syncNotifications();
  }

  Future<void> _loadEngagement() async {
    final appOpenCount = await _storageService.getAppOpenCount();
    final hasRated = await _storageService.getHasRated();
    if (!mounted) {
      return;
    }
    setState(() {
      _appOpenCount = appOpenCount;
      _hasRated = hasRated;
    });
  }

  Future<void> _openUrl(Uri uri) async {
    final ok =
        widget.urlLauncher != null
        ? await widget.urlLauncher!(uri)
        : await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
      );
    }
  }

  Future<void> _handleRating(int stars) async {
    await _storageService.setHasRated(true);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasRated = true;
    });

    if (stars <= 3) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const FeedbackScreen()),
      );
      return;
    }

    final storeUrl = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => AppConstants.iosStoreRatingUrl,
      TargetPlatform.android => AppConstants.androidStoreRatingUrl,
      _ => AppConstants.iosStoreRatingUrl,
    };
    await _openUrl(Uri.parse(storeUrl));
  }

  Future<void> _recalculateTimesIfPossible() async {
    final locationProvider = context.read<LocationProvider>();
    final prayerProvider = context.read<PrayerProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final location = locationProvider.location;
    if (location == null) {
      return;
    }
    await prayerProvider.recalculateForLocation(location);
    prayerProvider.startCountdown();
    final times = prayerProvider.prayerTimes;
    if (times != null) {
      if (widget.scheduleNotifications != null) {
        await widget.scheduleNotifications!(times, settingsProvider.settings);
      } else {
        await NotificationService().scheduleAllPrayerNotifications(
          times,
          settingsProvider.settings,
        );
      }
    }
  }

  Future<void> _syncNotifications() async {
    final times = context.read<PrayerProvider>().prayerTimes;
    if (times == null) {
      return;
    }
    final settings = context.read<SettingsProvider>().settings;
    if (widget.scheduleNotifications != null) {
      await widget.scheduleNotifications!(times, settings);
    } else {
      await NotificationService().scheduleAllPrayerNotifications(times, settings);
    }
  }

  Future<void> _togglePrayerPreview({
    required PrayerType prayerType,
    required SettingsModel settings,
  }) async {
    try {
      if (_previewPrayerType != null && _previewPrayerType != prayerType) {
        return;
      }
      final isSameActive = _previewPrayerType == prayerType;
      if (isSameActive) {
        await _audioService.stop();
        if (!mounted) {
          return;
        }
        setState(() {
          _previewPrayerType = null;
        });
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _previewPrayerType = prayerType;
      });
      await _audioService.stop();
      await _audioService.playFullAdhanForPrayer(
        prayerType: prayerType,
        selectedPackId: settings.selectedAdhanPackId,
        playPostAdhanDua: settings.postAdhanDuaEnabled,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _previewPrayerType = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildSnack(AppLocalizations.of(context)!.couldNotPlayPreview(error.toString())));
    }
  }

  @override
  void dispose() {
    AudioService.isPlaying.removeListener(_onPlayingChanged);
    _audioService.stop();
    super.dispose();
  }

  Future<void> _refreshLocationAndTimes() async {
    final ok = await context.read<LocationProvider>().refreshCurrentLocation();
    if (!mounted) {
      return;
    }
    if (ok) {
      await _recalculateTimesIfPossible();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildSnack(AppLocalizations.of(context)!.locationUpdated),
        );
      }
      return;
    }
    final message =
        context.read<LocationProvider>().errorMessage ??
        AppLocalizations.of(context)!.unableToGetLocation;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_buildSnack(message));
    }
  }

  Future<void> _openLocationPicker(_SettingsPalette palette) async {
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.backgroundColors.first,
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: palette.primaryText),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      style: TextStyle(color: palette.primaryText),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.cityOrAddress,
                        hintStyle: TextStyle(color: palette.secondaryText),
                        filled: true,
                        fillColor: palette.inputFill,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: palette.primaryText),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: palette.secondaryText,
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
                            tileColor: palette.sectionBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            title: Text(
                              item.cityName,
                              style: TextStyle(color: palette.primaryText),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: TextStyle(color: palette.secondaryText),
                            ),
                            trailing: Text(
                              item.countryCode,
                              style: TextStyle(color: palette.primaryText),
                            ),
                            onTap: () async {
                              await provider.setManualLocation(item);
                              if (!mounted) {
                                return;
                              }
                              await _recalculateTimesIfPossible();
                              if (!sheetContext.mounted || !context.mounted) {
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                _buildSnack(
                                  AppLocalizations.of(context)!.locationSetTo(item.cityName),
                                ),
                              );
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

  Future<void> _handleAdhanPackChange({
    required String value,
    required SettingsProvider provider,
    required SettingsModel settings,
  }) async {
    if (value == settings.selectedAdhanPackId) {
      return;
    }

    final selectedPack = AdhanPacks.byId(value);
    if (selectedPack.id != AdhanPacks.defaultPackId) {
      final isDownloaded = await _packDownloadService.isPackDownloaded(
        selectedPack.id,
      );
      if (!isDownloaded) {
        if (!mounted) {
          return;
        }
        final approve = await _showPremiumDownloadConfirmDialog(selectedPack);

        if (approve != true) {
          return;
        }

        if (!mounted) {
          return;
        }
        _showPremiumDownloadLoadingDialog();

        try {
          await _packDownloadService.downloadPack(selectedPack);
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        } catch (error) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(_buildSnack(AppLocalizations.of(context)!.downloadFailed(error.toString())));
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(_buildSnack(AppLocalizations.of(context)!.packDownloaded(selectedPack.name)));
        }
      }
    }

    await provider.saveSettings(settings.copyWith(selectedAdhanPackId: value));
  }

  Future<void> _openLanguagePicker(
    _SettingsPalette palette,
    SettingsProvider provider,
  ) async {
    final selectedLocale = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: palette.backgroundColors.first,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.language,
                  style: Theme.of(sheetContext).textTheme.headlineMedium
                      ?.copyWith(color: palette.primaryText),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: SupportedLocales.all.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final info = SupportedLocales.all[index];
                      final isCurrent = info.locale.languageCode ==
                          provider.settings.locale;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(sheetContext)
                              .pop(info.locale.languageCode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: palette.actionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? palette.selectedBg
                                    : palette.actionBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        info.nativeName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: palette.primaryText,
                                              fontWeight: isCurrent
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        info.englishName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: palette.secondaryText,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrent)
                                  Icon(
                                    Icons.check_rounded,
                                    color: palette.selectedBg,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedLocale == null || selectedLocale == provider.settings.locale) {
      return;
    }
    await provider.saveSettings(
      provider.settings.copyWith(locale: selectedLocale),
    );
    // Update widget and notifications with new locale
    if (mounted) {
      final prayerProvider = context.read<PrayerProvider>();
      prayerProvider.setLocale(selectedLocale);
      final times = prayerProvider.prayerTimes;
      if (times != null) {
        await WidgetService().updateWidget(times, locale: selectedLocale);
        await _syncNotifications();
      }
    }
  }

  Future<void> _openAdhanPackPicker({
    required _SettingsPalette palette,
    required SettingsProvider provider,
    required SettingsModel settings,
  }) async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: palette.backgroundColors.first,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.adhanPacks,
                  style: Theme.of(sheetContext).textTheme.headlineMedium
                      ?.copyWith(color: palette.primaryText),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: AdhanPacks.all.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final pack = AdhanPacks.all[index];
                      final isCurrent = pack.id == settings.selectedAdhanPackId;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(sheetContext).pop(pack.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: palette.actionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? palette.selectedBg
                                    : palette.actionBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    pack.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: palette.primaryText,
                                          fontWeight: isCurrent
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                  ),
                                ),
                                if (isCurrent)
                                  Icon(
                                    Icons.check_rounded,
                                    color: palette.selectedBg,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedId == null || selectedId == settings.selectedAdhanPackId) {
      return;
    }
    await _handleAdhanPackChange(
      value: selectedId,
      provider: provider,
      settings: settings,
    );
  }

  Future<bool?> _showPremiumDownloadConfirmDialog(AdhanPack selectedPack) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.70),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF111623).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFFFD98F).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD98F).withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.file_download_outlined,
                          color: Color(0xFFFFD98F),
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.downloadAdhanPack,
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFFFE6A8),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.adhanPackDownloadPrompt(selectedPack.name),
                          style: GoogleFonts.manrope(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.notNow,
                                  style: GoogleFonts.manrope(
                                    color: Colors.white54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD98F),
                                      Color(0xFFD4AF37),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFD98F,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.of(context)!.download,
                                          style: GoogleFonts.manrope(
                                            color: const Color(0xFF111623),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Future<void> _showPremiumDownloadLoadingDialog() {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Loading',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 44),
              decoration: BoxDecoration(
                color: const Color(0xFF111623).withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFD98F).withValues(alpha: 0.36),
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFD98F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.downloadingAdhanPack,
                            style: GoogleFonts.manrope(
                              color: const Color(0xFFE9EEFA),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
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
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  String _localizedPrayerName(BuildContext context, PrayerType type) {
    final l = AppLocalizations.of(context)!;
    switch (type) {
      case PrayerType.fajr: return l.prayerFajr;
      case PrayerType.sunrise: return l.prayerSunrise;
      case PrayerType.dhuhr: return l.prayerDhuhr;
      case PrayerType.asr: return l.prayerAsr;
      case PrayerType.maghrib: return l.prayerMaghrib;
      case PrayerType.isha: return l.prayerIsha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final prayerProvider = context.watch<PrayerProvider>();
    final settings = provider.settings;
    final selectedPack = AdhanPacks.byId(settings.selectedAdhanPackId);
    final configurablePrayerTypes = PrayerType.values
        .where((prayer) => prayer != PrayerType.sunrise)
        .toList(growable: false);
    final palette = _paletteFor(
      _resolvePhase(prayerProvider.prayerTimes, DateTime.now()),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.backgroundColors,
                  stops: palette.backgroundStops,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.78),
                    radius: 0.84,
                    colors: [
                      const Color(0xFFFFD98F).withValues(alpha: 0.17),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.09),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context)!.settings,
                      style: GoogleFonts.cinzel(
                        color: const Color(0xFFFFE6A8),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                PremiumSettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PremiumSectionHeader(title: AppLocalizations.of(context)!.location),
                      Text(
                        locationProvider.location?.cityName ??
                            AppLocalizations.of(context)!.noLocationSelected,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.primaryText,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (locationProvider.location != null)
                        Text(
                          '${locationProvider.location!.latitude.toStringAsFixed(4)}, '
                          '${locationProvider.location!.longitude.toStringAsFixed(4)}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: palette.secondaryText),
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          PremiumOutlinedButton(
                            text: AppLocalizations.of(context)!.useCurrentLocation,
                            icon: Icons.my_location_rounded,
                            isPrimary: true,
                            onPressed: _refreshLocationAndTimes,
                          ),
                          PremiumOutlinedButton(
                            text: AppLocalizations.of(context)!.searchLocation,
                            icon: Icons.search_rounded,
                            onPressed: () => _openLocationPicker(palette),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PremiumSettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PremiumSectionHeader(title: AppLocalizations.of(context)!.calculation),
                      DropdownButtonFormField<CalculationMethod>(
                        initialValue: settings.calculationMethod,
                        dropdownColor: palette.dropdownColor,
                        decoration: _fieldDecoration(palette),
                        items: CalculationMethod.values
                            .map(
                              (method) => DropdownMenuItem<CalculationMethod>(
                                value: method,
                                child: Text(
                                  _methodLabel(method, context),
                                  style: TextStyle(color: palette.primaryText),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (method) async {
                          if (method == null) {
                            return;
                          }
                          await provider.saveSettings(
                            settings.copyWith(calculationMethod: method),
                          );
                          await _recalculateTimesIfPossible();
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.asrMadhab,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ChoicePill<Madhab>(
                        palette: palette,
                        values: const [Madhab.nonHanafi, Madhab.hanafi],
                        selected: settings.madhab,
                        labelBuilder: (value) =>
                            value == Madhab.hanafi ? AppLocalizations.of(context)!.madhabHanafi : AppLocalizations.of(context)!.madhabNonHanafi,
                        onChanged: (value) async {
                          await provider.saveSettings(
                            settings.copyWith(madhab: value),
                          );
                          await _recalculateTimesIfPossible();
                        },
                      ),
                    ],
                  ),
                ),
                PremiumSettingsCard(
                  child: Opacity(
                    opacity: settings.notificationsEnabled ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PremiumSectionHeader(
                            title: AppLocalizations.of(context)!.notifications,
                            trailing: PremiumSwitch(
                              value: settings.notificationsEnabled,
                              onChanged: (value) async {
                                if (value) {
                                  if (widget.initializeNotifications != null) {
                                    await widget.initializeNotifications!();
                                  } else {
                                    await NotificationService().initialize();
                                  }
                                  final granted =
                                      widget.requestNotificationPermission != null
                                      ? await widget
                                            .requestNotificationPermission!()
                                      : await NotificationService()
                                            .requestPermission();
                                  if (!granted) {
                                    if (context.mounted) {
                                      showDialog<void>(
                                        context: context,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: Text(
                                            AppLocalizations.of(dialogCtx)!.permissionNeeded,
                                          ),
                                          content: Text(
                                            AppLocalizations.of(dialogCtx)!.pleaseAllowNotifications,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(dialogCtx).pop(),
                                              child: Text(AppLocalizations.of(dialogCtx)!.ok),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                }
                                await provider.saveSettings(
                                  settings.copyWith(
                                    notificationsEnabled: value,
                                  ),
                                );
                                await _syncNotifications();
                              },
                            ),
                          ),
                          for (final prayer in configurablePrayerTypes) ...[
                            _PrayerModeRow(
                              palette: palette,
                              prayerType: prayer,
                              prayerName: _localizedPrayerName(context, prayer),
                              selected:
                                  settings.prayerAlertModes[prayer] ??
                                  PrayerAlertMode.sound,
                              previewPrayerType: _previewPrayerType,
                              isPreviewLocked:
                                  _previewPrayerType != null &&
                                  _previewPrayerType != prayer,
                              onPreviewTap: () =>
                                  _togglePrayerPreview(
                                    prayerType: prayer,
                                    settings: settings,
                                  ),
                              onChanged: (mode) async {
                                final updatedModes =
                                    Map<PrayerType, PrayerAlertMode>.from(
                                      settings.prayerAlertModes,
                                    );
                                updatedModes[prayer] = mode;
                                final updatedEnabled = <PrayerType, bool>{
                                  for (final p in PrayerType.values)
                                    p:
                                        (updatedModes[p] ??
                                            PrayerAlertMode.sound) !=
                                        PrayerAlertMode.off,
                                };
                                updatedModes[PrayerType.sunrise] =
                                    PrayerAlertMode.off;
                                updatedEnabled[PrayerType.sunrise] = false;
                                await provider.saveSettings(
                                  settings.copyWith(
                                    prayerAlertModes: updatedModes,
                                    enabledPrayers: updatedEnabled,
                                  ),
                                );
                                await _syncNotifications();
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                PremiumSettingsCard(
                  child: Column(
                    children: [
                      PremiumSectionHeader(title: AppLocalizations.of(context)!.adhanAudio),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.actionBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.actionBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.graphic_eq_rounded,
                              color: palette.primaryText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.fullAdhanOnNotificationTap,
                                style: TextStyle(color: palette.primaryText),
                              ),
                            ),
                            PremiumSwitch(
                              value: settings.adhanSoundEnabled,
                              onChanged: (value) async {
                                await provider.saveSettings(
                                  settings.copyWith(adhanSoundEnabled: value),
                                );
                                await _syncNotifications();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.actionBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.actionBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: palette.primaryText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.playDuaAfterAdhan,
                                style: TextStyle(color: palette.primaryText),
                              ),
                            ),
                            PremiumSwitch(
                              value: settings.postAdhanDuaEnabled,
                              onChanged: (value) async {
                                await provider.saveSettings(
                                  settings.copyWith(
                                    postAdhanDuaEnabled: value,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openAdhanPackPicker(
                          palette: palette,
                          provider: provider,
                          settings: settings,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: palette.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: palette.actionBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.library_music_rounded,
                                color: palette.primaryText,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.adhanPackLabel(selectedPack.name),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: palette.primaryText),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: palette.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PremiumSettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PremiumSectionHeader(title: AppLocalizations.of(context)!.language),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openLanguagePicker(palette, provider),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: palette.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: palette.actionBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.language_rounded,
                                color: palette.primaryText,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  SupportedLocales.all
                                      .firstWhere(
                                        (l) => l.locale.languageCode == settings.locale,
                                        orElse: () => SupportedLocales.all.first,
                                      )
                                      .nativeName,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: palette.primaryText),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: palette.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PremiumSettingsCard(
                  child: Column(
                    children: [
                      PremiumSectionHeader(title: AppLocalizations.of(context)!.supportAndTrust),
                      PremiumActionTile(
                        icon: Icons.favorite_border_rounded,
                        title: AppLocalizations.of(context)!.donate,
                        subtitle: AppLocalizations.of(context)!.donateSubtitle,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const DonateScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      PremiumActionTile(
                        icon: Icons.mail_outline_rounded,
                        title: AppLocalizations.of(context)!.sendFeedback,
                        subtitle: AppLocalizations.of(context)!.sendFeedbackSubtitle,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const FeedbackScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      PremiumActionTile(
                        icon: Icons.widgets_outlined,
                        title: AppLocalizations.of(context)!.widgetSetup,
                        subtitle:
                            AppLocalizations.of(context)!.widgetSetupSubtitle,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const WidgetPreviewScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      PremiumActionTile(
                        icon: Icons.privacy_tip_outlined,
                        title: AppLocalizations.of(context)!.privacyNotes,
                        subtitle: AppLocalizations.of(context)!.privacyNotesSubtitle,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PrivacyNotesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_showRatePrompt)
                        _RateCard(palette: palette, onRate: _handleRating),
                      if (!_showRatePrompt)
                        Text(
                          AppLocalizations.of(context)!.thankYouForUsing,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: palette.secondaryText),
                        ),
                      const SizedBox(height: 12),
                      Divider(color: palette.dividerColor),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.appAlwaysFree,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _fieldDecoration(_SettingsPalette palette) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.actionBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.actionBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.sectionBorder, width: 1.4),
      ),
      filled: true,
      fillColor: palette.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  static String _methodLabel(CalculationMethod method, BuildContext context) {
    final l = AppLocalizations.of(context)!;
    switch (method) {
      case CalculationMethod.isna:
        return l.methodIsna;
      case CalculationMethod.muslimWorldLeague:
        return l.methodMuslimWorldLeague;
      case CalculationMethod.turkeyDiyanet:
        return l.methodTurkeyDiyanet;
      case CalculationMethod.egyptian:
        return l.methodEgyptian;
      case CalculationMethod.karachi:
        return l.methodKarachi;
      case CalculationMethod.ummAlQura:
        return l.methodUmmAlQura;
      case CalculationMethod.dubai:
        return l.methodDubai;
      case CalculationMethod.singapore:
        return l.methodSingapore;
      case CalculationMethod.tehran:
        return l.methodTehran;
    }
  }

  _SettingsPhase _resolvePhase(PrayerTimesModel? times, DateTime now) {
    if (times == null) {
      return _SettingsPhase.night;
    }

    final ordered = <MapEntry<PrayerType, DateTime>>[
      MapEntry(PrayerType.fajr, times.fajr),
      MapEntry(PrayerType.sunrise, times.sunrise),
      MapEntry(PrayerType.dhuhr, times.dhuhr),
      MapEntry(PrayerType.asr, times.asr),
      MapEntry(PrayerType.maghrib, times.maghrib),
      MapEntry(PrayerType.isha, times.isha),
    ];

    PrayerType active = PrayerType.isha;
    if (now.isBefore(ordered.first.value)) {
      active = PrayerType.isha;
    } else {
      for (int i = 0; i < ordered.length; i++) {
        final current = ordered[i];
        final next = i + 1 < ordered.length
            ? ordered[i + 1].value
            : ordered.first.value.add(const Duration(days: 1));
        if ((now.isAtSameMomentAs(current.value) ||
                now.isAfter(current.value)) &&
            now.isBefore(next)) {
          active = current.key;
          break;
        }
      }
      if (now.isAfter(ordered.last.value)) {
        active = PrayerType.isha;
      }
    }

    switch (active) {
      case PrayerType.isha:
        return _SettingsPhase.night;
      case PrayerType.fajr:
        return _SettingsPhase.dawn;
      case PrayerType.sunrise:
      case PrayerType.dhuhr:
      case PrayerType.asr:
        return _SettingsPhase.day;
      case PrayerType.maghrib:
        return _SettingsPhase.night;
    }
  }

  _SettingsPalette _paletteFor(_SettingsPhase phase) {
    switch (phase) {
      case _SettingsPhase.night:
        return const _SettingsPalette(
          backgroundColors: <Color>[
            Color(0xFF02030A),
            Color(0xFF071330),
            Color(0xFF02030A),
          ],
          backgroundStops: <double>[0.0, 0.55, 1.0],
          primaryText: Color(0xFFEFF3FF),
          secondaryText: Color(0xB3D2DAF3),
          sectionBg: Color(0x99111623),
          sectionBorder: Color(0x66FFD98F),
          sectionShadow: Color(0x4D000000),
          pillBg: Color(0x22FFFFFF),
          selectedBg: Color(0xB8FFD98F),
          selectedFg: Color(0xFF12203A),
          rowChipBg: Color(0x1AFFFFFF),
          rowChipBorder: Color(0x29FFFFFF),
          rowIconUnselected: Color(0xB3D2DAF3),
          actionBg: Color(0x33101623),
          actionBorder: Color(0x66FFD98F),
          inputFill: Color(0x38111822),
          dropdownColor: Color(0xFF1A2743),
          dividerColor: Color(0x40FFFFFF),
        );
      case _SettingsPhase.dawn:
        return const _SettingsPalette(
          backgroundColors: <Color>[
            Color(0xFF1B1232),
            Color(0xFF3D2C4E),
            Color(0xFF6A4152),
          ],
          backgroundStops: <double>[0.0, 0.6, 1.0],
          primaryText: Color(0xFFF8F0E7),
          secondaryText: Color(0xD9E8D5C4),
          sectionBg: Color(0x9922162D),
          sectionBorder: Color(0x66FFD98F),
          sectionShadow: Color(0x44000000),
          pillBg: Color(0x24FFFFFF),
          selectedBg: Color(0xB8F5C98A),
          selectedFg: Color(0xFF2E223B),
          rowChipBg: Color(0x1FFFFFFF),
          rowChipBorder: Color(0x33FFFFFF),
          rowIconUnselected: Color(0xC8F2E4D4),
          actionBg: Color(0x3323182C),
          actionBorder: Color(0x66FFD98F),
          inputFill: Color(0x3321152A),
          dropdownColor: Color(0xFF3A2C4D),
          dividerColor: Color(0x52FFFFFF),
        );
      case _SettingsPhase.day:
        return const _SettingsPalette(
          backgroundColors: <Color>[
            Color(0xFFB9883D),
            Color(0xFFD1A75F),
            Color(0xFFE5BF7A),
          ],
          backgroundStops: <double>[0.0, 0.58, 1.0],
          primaryText: Color(0xFFFFE6A8),
          secondaryText: Color(0xE6FFF8EC),
          sectionBg: Color(0xB39A7238),
          sectionBorder: Color(0x66FFD98F),
          sectionShadow: Color(0x332A1A08),
          pillBg: Color(0x66F1DDAC),
          selectedBg: Color(0xFFA66722),
          selectedFg: Color(0xFFF8ECD0),
          rowChipBg: Color(0x66F2DEB0),
          rowChipBorder: Color(0x80D9AB50),
          rowIconUnselected: Color(0xCCFFF5E2),
          actionBg: Color(0x66EAD2A2),
          actionBorder: Color(0x66FFD98F),
          inputFill: Color(0x66F1DDAC),
          dropdownColor: Color(0xFFD9B574),
          dividerColor: Color(0x665A3F20),
        );
    }
  }
}

class _ChoicePill<T> extends StatelessWidget {
  const _ChoicePill({
    required this.palette,
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  final _SettingsPalette palette;
  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final Future<void> Function(T value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.pillBg,
      ),
      child: Row(
        children: values.map((value) {
          final isSelected = value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? palette.selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labelBuilder(value),
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: isSelected
                            ? palette.selectedFg
                            : palette.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PrayerModeRow extends StatelessWidget {
  const _PrayerModeRow({
    required this.palette,
    required this.prayerType,
    required this.prayerName,
    required this.selected,
    required this.previewPrayerType,
    required this.isPreviewLocked,
    required this.onPreviewTap,
    required this.onChanged,
  });

  final _SettingsPalette palette;
  final PrayerType prayerType;
  final String prayerName;
  final PrayerAlertMode selected;
  final PrayerType? previewPrayerType;
  final bool isPreviewLocked;
  final Future<void> Function() onPreviewTap;
  final Future<void> Function(PrayerAlertMode mode) onChanged;

  @override
  Widget build(BuildContext context) {
    const modes = <PrayerAlertMode>[
      PrayerAlertMode.off,
      PrayerAlertMode.silent,
      PrayerAlertMode.vibrate,
      PrayerAlertMode.sound,
    ];

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isPreviewLocked ? null : onPreviewTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isPlayingThisPrayer
                  ? palette.selectedBg
                  : palette.rowChipBg,
              border: Border.all(
                color: isPreviewLocked
                    ? palette.rowChipBorder.withValues(alpha: 0.45)
                    : palette.rowChipBorder,
              ),
            ),
            child: Icon(
              isPlayingThisPrayer ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: isPreviewLocked
                  ? palette.rowIconUnselected.withValues(alpha: 0.35)
                  : isPlayingThisPrayer
                  ? palette.selectedFg
                  : palette.rowIconUnselected,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            prayerName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              color: palette.primaryText,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: palette.rowChipBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.rowChipBorder),
          ),
          child: Row(
            children: modes.map((mode) {
              final isSelected = selected == mode;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onChanged(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? palette.selectedBg
                          : Colors.transparent,
                    ),
                    child: Icon(
                      _modeIcon(mode),
                      color: isSelected
                          ? palette.selectedFg
                          : palette.rowIconUnselected,
                      size: 21,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool get isPlayingThisPrayer =>
      previewPrayerType == prayerType;

  IconData _modeIcon(PrayerAlertMode mode) {
    switch (mode) {
      case PrayerAlertMode.off:
        return Icons.notifications_off_rounded;
      case PrayerAlertMode.silent:
        return Icons.notifications_none_rounded;
      case PrayerAlertMode.vibrate:
        return Icons.vibration_rounded;
      case PrayerAlertMode.sound:
        return Icons.mosque_rounded;
    }
  }
}

class _RateCard extends StatefulWidget {
  const _RateCard({required this.palette, required this.onRate});

  final _SettingsPalette palette;
  final Future<void> Function(int stars) onRate;

  @override
  State<_RateCard> createState() => _RateCardState();
}

class _RateCardState extends State<_RateCard> {
  int _selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.palette.actionBg,
        border: Border.all(color: widget.palette.actionBorder),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.rateDigitalMinaret,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: widget.palette.primaryText),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final stars = i + 1;
              final selected = _selectedStars >= stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      _selectedStars = stars;
                    });
                    await widget.onRate(stars);
                  },
                  icon: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    color: selected
                        ? Colors.amber.shade300
                        : widget.palette.secondaryText,
                  ),
                  iconSize: 34,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

enum _SettingsPhase { night, dawn, day }

class _SettingsPalette {
  const _SettingsPalette({
    required this.backgroundColors,
    required this.backgroundStops,
    required this.primaryText,
    required this.secondaryText,
    required this.sectionBg,
    required this.sectionBorder,
    required this.sectionShadow,
    required this.pillBg,
    required this.selectedBg,
    required this.selectedFg,
    required this.rowChipBg,
    required this.rowChipBorder,
    required this.rowIconUnselected,
    required this.actionBg,
    required this.actionBorder,
    required this.inputFill,
    required this.dropdownColor,
    required this.dividerColor,
  });

  final List<Color> backgroundColors;
  final List<double> backgroundStops;
  final Color primaryText;
  final Color secondaryText;
  final Color sectionBg;
  final Color sectionBorder;
  final Color sectionShadow;
  final Color pillBg;
  final Color selectedBg;
  final Color selectedFg;
  final Color rowChipBg;
  final Color rowChipBorder;
  final Color rowIconUnselected;
  final Color actionBg;
  final Color actionBorder;
  final Color inputFill;
  final Color dropdownColor;
  final Color dividerColor;
}
