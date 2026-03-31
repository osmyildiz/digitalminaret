import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/prayer_type.dart';
import '../../core/labels/prayer_label_resolver.dart';
import '../../core/rules/season_rules_service.dart';
import '../../core/time/date_time_provider.dart';
import '../../data/models/prayer_times_model.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/storage_service.dart';
import '../providers/location_provider.dart';
import '../providers/prayer_provider.dart';
import '../widgets/mini_qibla_compass.dart';
import '../../l10n/app_localizations.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.dateTimeProvider = const SystemDateTimeProvider(),
    this.seasonRulesService = const DefaultSeasonRulesService(),
    this.prayerLabelResolver = const PrayerLabelResolver(),
    this.showQiblaCompass = true,
  });

  final DateTimeProvider dateTimeProvider;
  final SeasonRulesService seasonRulesService;
  final PrayerLabelResolver prayerLabelResolver;
  final bool showQiblaCompass;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();
  late final AnimationController _particleController;
  late final List<_OrnamentConfig> _ramadanOrnaments;
  static const bool _showRamadanHangingDecor = true;
  static const bool _debugForcePhase = false;
  static const _ThemePhase _debugForcedPhase = _ThemePhase.night;
  bool _ratePromptChecked = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _ramadanOrnaments = _buildRandomRamadanOrnaments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowRatePrompt();
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final prayerTimes = prayerProvider.prayerTimes;

    if (prayerTimes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final now = widget.dateTimeProvider.now();
    final model = _buildTimingModel(prayerTimes, now);
    final phase = _debugForcePhase
        ? _debugForcedPhase
        : _phaseByPrayer(model.activePrayer);
    final isRamadan = widget.seasonRulesService.isRamadan(
      now,
      cityName: locationProvider.location?.cityName,
    );
    final isIftarCountdown =
        isRamadan &&
        model.nextPrayer == PrayerType.maghrib &&
        model.timeUntilNext <= const Duration(hours: 1);
    final iftarWarmth = isIftarCountdown
        ? (1 -
              (model.timeUntilNext.inSeconds /
                      const Duration(hours: 1).inSeconds)
                  .clamp(0.0, 1.0))
        : 0.0;
    final palette = _paletteFor(phase);
    final dynamicConeColor = Color.lerp(
      palette.coneColor,
      const Color(0xFFFFA85C),
      iftarWarmth,
    )!;
    final dynamicAccentColor = Color.lerp(
      palette.accentColor,
      const Color(0xFFFFB066),
      iftarWarmth,
    )!;
    final isDayTime = phase == _ThemePhase.day;
    final primaryTextColor = isDayTime
        ? const Color(0xFF14233D)
        : palette.primaryTextColor;
    final accentColor = isDayTime
        ? const Color(0xFFA66722)
        : dynamicAccentColor;
    final textShadows = isDayTime
        ? <Shadow>[
            Shadow(color: Colors.white.withValues(alpha: 0.26), blurRadius: 12),
          ]
        : <Shadow>[
            Shadow(
              color: const Color(0xFFFFD98F).withValues(alpha: 0.55),
              blurRadius: 34,
            ),
          ];

    final activePrayerName = _displayPrayerName(
      context,
      model.activePrayer,
      now,
      isRamadan,
    );
    final activePrayerArabic = _arabicByPrayer(model.activePrayer, now);
    final activePrayerTime = DateFormat(
      'h:mm a',
    ).format(model.activePrayerTime);
    final nextPrayerTime = DateFormat('h:mm a').format(model.nextPrayerTime);
    final nextPrayerName = _displayPrayerName(context, model.nextPrayer, now, isRamadan);
    final l = AppLocalizations.of(context)!;
    final nextLabel = isRamadan
        ? (model.nextPrayer == PrayerType.fajr
              ? l.suhoorEnds
              : model.nextPrayer == PrayerType.maghrib
              ? l.iftarTime
              : nextPrayerName.toUpperCase())
        : nextPrayerName.toUpperCase();
    final isJumuahActive =
        now.weekday == DateTime.friday &&
        model.activePrayer == PrayerType.dhuhr;
    final eidLabel = widget.seasonRulesService.eidPrayerLabel(now);
    final eidPrayerTime = DateFormat(
      'h:mm a',
    ).format(prayerTimes.sunrise.add(const Duration(minutes: 45)));
    final phaseProgress = _phaseProgress(
      start: model.activePrayerTime,
      end: model.nextPrayerTime,
      now: now,
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: palette.backgroundColors.first,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
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
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    animationValue: _particleController.value,
                    count: isRamadan
                        ? (palette.particleCount * 1.2).round()
                        : palette.particleCount,
                    color: palette.particleColor,
                    minRadius: palette.particleMinRadius,
                    maxRadius: palette.particleMaxRadius,
                    maxOpacity: isRamadan
                        ? (palette.particleMaxOpacity + 0.06).clamp(0.0, 1.0)
                        : palette.particleMaxOpacity,
                    style: palette.particleStyle,
                  ),
                );
              },
            ),
          ),
          if (iftarWarmth > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(
                          0xFFFF9A4A,
                        ).withValues(alpha: 0.16 * iftarWarmth),
                        Colors.transparent,
                        const Color(
                          0xFFFF7E3F,
                        ).withValues(alpha: 0.12 * iftarWarmth),
                      ],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
          if (palette.showPattern)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  opacity: palette.patternOpacity,
                  child: CustomPaint(
                    painter: _SacredPatternPainter(color: palette.patternColor),
                  ),
                ),
              ),
            ),
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SizedBox(
                height: size.height * 0.92,
                child: CustomPaint(
                  painter: _LightConePainter(
                    color: dynamicConeColor,
                    intensity: palette.coneIntensity,
                    isDayTime: isDayTime,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('d MMM y').format(now),
                                    style: GoogleFonts.cinzel(
                                      color: palette.topMetaColor,
                                      fontSize: 13,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: palette.topMetaColor.withValues(
                                          alpha: 0.8,
                                        ),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        locationProvider.location?.cityName ??
                                            AppLocalizations.of(context)!.unknown,
                                        style: GoogleFonts.manrope(
                                          color: palette.topMetaColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ValueListenableBuilder<bool>(
                                    valueListenable: AudioService.isPlaying,
                                    builder: (context, playing, _) {
                                      if (!playing) {
                                        return const SizedBox.shrink();
                                      }
                                      return ValueListenableBuilder<bool>(
                                        valueListenable: AudioService.isMuted,
                                        builder: (context, muted, _) {
                                          return IconButton(
                                            onPressed: _audioService.toggleMute,
                                            icon: Icon(
                                              muted
                                                  ? Icons.volume_off_rounded
                                                  : Icons.volume_up_rounded,
                                              color: accentColor,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  if (widget.showQiblaCompass)
                                    const MiniQiblaCompass()
                                  else
                                    const SizedBox(width: 34),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              const SettingsScreen(),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.tune_rounded,
                                      color: palette.topMetaColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            activePrayerArabic,
                            style: GoogleFonts.amiri(
                              fontSize: 84,
                              height: 1,
                              color: accentColor,
                              shadows: textShadows,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activePrayerName.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              color: accentColor,
                              letterSpacing: 2.4,
                              fontSize: 44,
                              fontWeight: FontWeight.w600,
                              shadows: textShadows,
                            ),
                          ),
                          Text(
                            activePrayerTime,
                            style: GoogleFonts.manrope(
                              color: primaryTextColor,
                              fontSize: 38,
                              fontWeight: isDayTime
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          ),
                          if (isJumuahActive) const SizedBox(height: 4),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: 176,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.11,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: phaseProgress,
                                        child: Container(
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: accentColor,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: accentColor.withValues(
                                                  alpha: 0.5,
                                                ),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _durationText(model.timeUntilNext),
                                      style: GoogleFonts.manrope(
                                        color: isDayTime
                                            ? primaryTextColor
                                            : Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '$nextLabel  $nextPrayerTime',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cinzel(
                                        color: isDayTime
                                            ? primaryTextColor
                                            : accentColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                                if (eidLabel != null) ...[
                                  const SizedBox(height: 7),
                                  Text(
                                    '✨ ${eidLabel.toUpperCase()} ✨  $eidPrayerTime',
                                    style: GoogleFonts.cinzel(
                                      color: accentColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.7,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 90),
                          AnimatedBuilder(
                            animation: _particleController,
                            builder: (context, child) {
                              final drift =
                                  math.sin(
                                    _particleController.value * math.pi * 2,
                                  ) *
                                  7;
                              return Transform.translate(
                                offset: Offset(0, drift),
                                child: child,
                              );
                            },
                            child: SizedBox(
                              width: 16,
                              height: 90,
                              child: CustomPaint(
                                painter: _SlimDownArrowPainter(
                                  color: accentColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.seasonRulesService.hijriDateText(now),
                            style: GoogleFonts.cinzel(
                              color: palette.bottomDateColor,
                              fontSize: 16,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: palette.accentColor.withValues(
                                    alpha: 0.24,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            locationProvider.location?.cityName ?? AppLocalizations.of(context)!.unknown,
                            style: GoogleFonts.manrope(
                              color: palette.bottomMetaColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 22),
                          AnimatedBuilder(
                            animation: _particleController,
                            builder: (context, child) {
                              final drift =
                                  math.sin(
                                    (_particleController.value * math.pi * 2) +
                                        1.2,
                                  ) *
                                  5;
                              return Transform.translate(
                                offset: Offset(0, drift),
                                child: child,
                              );
                            },
                            child: SizedBox(
                              width: 12,
                              height: 14,
                              child: CustomPaint(
                                painter: _ThinChevronDownPainter(
                                  color: palette.topMetaColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, palette.listOverlayColor],
                      ),
                    ),
                    child: Column(
                      children: _buildPrayerRows(
                        prayerTimes,
                        model,
                        now,
                        palette,
                        isDayTime,
                        isRamadan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRamadan && _showRamadanHangingDecor)
            Positioned(
              top: 0,
              left: 84,
              right: 84,
              child: _RamadanHangingDecor(
                animationValue: _particleController.value,
                accentColor: accentColor,
                ornaments: _ramadanOrnaments,
              ),
            ),
        ],
      ),
    );
  }

  List<_OrnamentConfig> _buildRandomRamadanOrnaments() {
    final random = math.Random();
    final iconPool = <IconData>[
      FlutterIslamicIcons.solidLantern,
      FlutterIslamicIcons.solidCrescentMoon,
      FlutterIslamicIcons.solidMinaret,
      FlutterIslamicIcons.solidQibla,
    ];

    IconData randomIcon() => iconPool[random.nextInt(iconPool.length)];

    return <_OrnamentConfig>[
      _OrnamentConfig(
        xFactor: 0.06,
        lineHeight: 96,
        iconSize: 14,
        icon: Icons.star_rounded,
        phaseShift: 0.15,
        motionAmplitude: 3,
        speedFactor: 0.95,
      ),
      _OrnamentConfig(
        xFactor: 0.20,
        lineHeight: (78 + random.nextInt(44)).toDouble(),
        iconSize: (14 + random.nextInt(4)).toDouble(),
        icon: randomIcon(),
        phaseShift: random.nextDouble(),
        motionAmplitude: (5 + random.nextInt(6)).toDouble(),
        speedFactor: 0.92 + random.nextDouble() * 0.16,
        onTap: _showHadithFromOrnament,
        tooltip: 'Hadith of the Day',
      ),
      _OrnamentConfig(
        xFactor: 0.34,
        lineHeight: (78 + random.nextInt(52)).toDouble(),
        iconSize: (14 + random.nextInt(5)).toDouble(),
        icon: randomIcon(),
        phaseShift: random.nextDouble(),
        motionAmplitude: (5 + random.nextInt(7)).toDouble(),
        speedFactor: 0.92 + random.nextDouble() * 0.16,
      ),
      _OrnamentConfig(
        xFactor: 0.50,
        lineHeight: (88 + random.nextInt(56)).toDouble(),
        iconSize: (16 + random.nextInt(5)).toDouble(),
        icon: randomIcon(),
        phaseShift: random.nextDouble(),
        motionAmplitude: (8 + random.nextInt(5)).toDouble(),
        speedFactor: 0.94 + random.nextDouble() * 0.14,
        onTap: _showDuaFromOrnament,
        tooltip: 'Ramadan Dua',
      ),
      _OrnamentConfig(
        xFactor: 0.66,
        lineHeight: (78 + random.nextInt(52)).toDouble(),
        iconSize: (14 + random.nextInt(5)).toDouble(),
        icon: randomIcon(),
        phaseShift: random.nextDouble(),
        motionAmplitude: (5 + random.nextInt(7)).toDouble(),
        speedFactor: 0.92 + random.nextDouble() * 0.16,
      ),
      _OrnamentConfig(
        xFactor: 0.80,
        lineHeight: (78 + random.nextInt(44)).toDouble(),
        iconSize: (14 + random.nextInt(4)).toDouble(),
        icon: randomIcon(),
        phaseShift: random.nextDouble(),
        motionAmplitude: (5 + random.nextInt(6)).toDouble(),
        speedFactor: 0.92 + random.nextDouble() * 0.16,
        onTap: _showVerseFromOrnament,
        tooltip: 'Verse from the Quran',
      ),
      _OrnamentConfig(
        xFactor: 0.94,
        lineHeight: 96,
        iconSize: 14,
        icon: Icons.star_rounded,
        phaseShift: 0.73,
        motionAmplitude: 3,
        speedFactor: 0.95,
      ),
    ];
  }

  void _showHadithFromOrnament() {
    final l = AppLocalizations.of(context)!;
    _showRamadanContentDialog(
      title: l.hadithOfTheDay,
      body: l.hadithBody,
    );
  }

  void _showDuaFromOrnament() {
    final l = AppLocalizations.of(context)!;
    _showRamadanContentDialog(
      title: l.ramadanDua,
      body: l.duaBody,
    );
  }

  void _showVerseFromOrnament() {
    final l = AppLocalizations.of(context)!;
    _showRamadanContentDialog(
      title: l.verseFromQuran,
      body: l.verseBody,
    );
  }

  Future<void> _maybeShowRatePrompt() async {
    if (_ratePromptChecked || !mounted) {
      return;
    }
    _ratePromptChecked = true;

    final appOpenCount = await _storageService.getAppOpenCount();
    final hasRated = await _storageService.getHasRated();
    final shouldPrompt = AppConstants.shouldShowRatePrompt(
      appOpenCount: appOpenCount,
      hasRated: hasRated,
    );
    if (!mounted || !shouldPrompt) {
      return;
    }

    final selectedStars = await _showPremiumRatingDialog(context);

    if (selectedStars == null || !mounted) {
      return;
    }
    await _storageService.setHasRated(true);

    if (selectedStars <= 3) {
      final uri = Uri(
        scheme: 'mailto',
        path: AppConstants.feedbackEmail,
        query:
            'subject=Digital Minaret Feedback&body=I rated the app $selectedStars star(s).%0A',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    final storeUrl = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => AppConstants.iosStoreRatingUrl,
      TargetPlatform.android => AppConstants.androidStoreRatingUrl,
      _ => AppConstants.iosStoreRatingUrl,
    };
    await launchUrl(
      Uri.parse(storeUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<int?> _showPremiumRatingDialog(BuildContext context) {
    int selectedStars = 0;
    return showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
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
                      filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_border_purple500_outlined,
                              color: Color(0xFFFFD98F),
                              size: 40,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.rateDigitalMinaret,
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
                              AppLocalizations.of(context)!.ratePromptMessage,
                              style: GoogleFonts.manrope(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starValue = index + 1;
                                final isFilled = selectedStars >= starValue;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      setState(() {
                                        selectedStars = starValue;
                                      });
                                    },
                                    child: Icon(
                                      isFilled
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: isFilled
                                          ? const Color(0xFFFFD98F)
                                          : Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                      size: 36,
                                      shadows: isFilled
                                          ? [
                                              Shadow(
                                                color: const Color(
                                                  0xFFFFD98F,
                                                ).withValues(alpha: 0.5),
                                                blurRadius: 10,
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
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
                                        onTap: () {
                                          final result = selectedStars == 0
                                              ? 5
                                              : selectedStars;
                                          Navigator.of(
                                            dialogContext,
                                          ).pop(result);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppLocalizations.of(context)!.submit,
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
                );
              },
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

  Future<void> _showRamadanContentDialog({
    required String title,
    required String body,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF111623).withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFD98F).withValues(alpha: 0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD98F).withValues(alpha: 0.14),
                    blurRadius: 26,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            color: const Color(0xFFFFE6A8),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          body,
                          style: GoogleFonts.manrope(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              AppLocalizations.of(context)!.close,
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFFFD98F),
                                fontWeight: FontWeight.w700,
                              ),
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
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  List<Widget> _buildPrayerRows(
    PrayerTimesModel times,
    _TimingModel model,
    DateTime now,
    _PhasePalette palette,
    bool isDayTime,
    bool isRamadan,
  ) {
    final entries = <_PrayerEntry>[
      _PrayerEntry(PrayerType.fajr, times.fajr),
      _PrayerEntry(PrayerType.sunrise, times.sunrise),
      _PrayerEntry(PrayerType.dhuhr, times.dhuhr),
      _PrayerEntry(PrayerType.asr, times.asr),
      _PrayerEntry(PrayerType.maghrib, times.maghrib),
      _PrayerEntry(PrayerType.isha, times.isha),
    ];

    final l = AppLocalizations.of(context)!;
    return entries.map((entry) {
      final isActive = entry.type == model.activePrayer;
      final isPassed = now.isAfter(entry.time) && !isActive;

      if (isActive) {
        final nextPrayerName = _displayPrayerName(
          context,
          model.nextPrayer,
          now,
          isRamadan,
        );
        final nextLabel = isRamadan
            ? (model.nextPrayer == PrayerType.fajr
                  ? l.suhoorEnds
                  : model.nextPrayer == PrayerType.maghrib
                  ? l.iftarTime
                  : nextPrayerName.toUpperCase())
            : nextPrayerName.toUpperCase();

        return _ActivePrayerCard(
          prayerName: _displayPrayerName(context, entry.type, now, isRamadan),
          prayerArabic: _arabicByPrayer(entry.type, now),
          time: DateFormat('h:mm a').format(entry.time),
          nextInfo: '$nextLabel in ${_durationText(model.timeUntilNext)}',
          icon: _iconByPrayer(entry.type),
          palette: palette,
        );
      }

      return _InactivePrayerRow(
        prayerName: _displayPrayerName(context, entry.type, now, isRamadan),
        time: DateFormat('h:mm a').format(entry.time),
        icon: _iconByPrayer(entry.type),
        faded: isPassed,
        textColor: isDayTime
            ? palette.activeCardTextColor
            : palette.inactiveTextColor,
        fadedOpacity: isDayTime ? 1.0 : 0.55,
      );
    }).toList();
  }

  _TimingModel _buildTimingModel(PrayerTimesModel times, DateTime now) {
    final ordered = <MapEntry<PrayerType, DateTime>>[
      MapEntry(PrayerType.fajr, times.fajr),
      MapEntry(PrayerType.sunrise, times.sunrise),
      MapEntry(PrayerType.dhuhr, times.dhuhr),
      MapEntry(PrayerType.asr, times.asr),
      MapEntry(PrayerType.maghrib, times.maghrib),
      MapEntry(PrayerType.isha, times.isha),
    ];

    PrayerType active = PrayerType.isha;
    PrayerType nextPrayer = PrayerType.fajr;
    DateTime activeTime = ordered.last.value;
    DateTime nextTime = ordered.first.value;

    if (now.isBefore(ordered.first.value)) {
      active = PrayerType.isha;
      activeTime = ordered.last.value.subtract(const Duration(days: 1));
      nextPrayer = ordered.first.key;
      nextTime = ordered.first.value;
    } else {
      for (int i = 0; i < ordered.length; i++) {
        final current = ordered[i];
        final nextEntry = i + 1 < ordered.length
            ? ordered[i + 1]
            : MapEntry(
                ordered.first.key,
                ordered.first.value.add(const Duration(days: 1)),
              );

        if ((now.isAtSameMomentAs(current.value) ||
                now.isAfter(current.value)) &&
            now.isBefore(nextEntry.value)) {
          active = current.key;
          activeTime = current.value;
          nextPrayer = nextEntry.key;
          nextTime = nextEntry.value;
          break;
        }
      }

      if (now.isAfter(ordered.last.value)) {
        active = ordered.last.key;
        activeTime = ordered.last.value;
        nextPrayer = ordered.first.key;
        nextTime = ordered.first.value.add(const Duration(days: 1));
      }
    }

    return _TimingModel(
      activePrayer: active,
      activePrayerTime: activeTime,
      nextPrayer: nextPrayer,
      nextPrayerTime: nextTime,
      timeUntilNext: nextTime.difference(now).isNegative
          ? Duration.zero
          : nextTime.difference(now),
    );
  }

  _ThemePhase _phaseByPrayer(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return _ThemePhase.dawnFajr;
      case PrayerType.sunrise:
      case PrayerType.dhuhr:
      case PrayerType.asr:
        return _ThemePhase.day;
      case PrayerType.maghrib:
      case PrayerType.isha:
        return _ThemePhase.night;
    }
  }

  _PhasePalette _paletteFor(_ThemePhase phase) {
    switch (phase) {
      case _ThemePhase.night:
        return const _PhasePalette(
          backgroundColors: <Color>[
            Color(0xFF02030A),
            Color(0xFF071330),
            Color(0xFF02030A),
          ],
          accentColor: Color(0xFFFFD98F),
          primaryTextColor: Color(0xFFEFF3FF),
          topMetaColor: Color(0xFFCFD7F0),
          chipBackground: Color(0x1AFFFFFF),
          chipBorder: Color(0x2AFFFFFF),
          bottomDateColor: Color(0xDCE6D4A3),
          bottomMetaColor: Color(0x66FFFFFF),
          listOverlayColor: Color(0xCC03040A),
          activeCardColor: Color(0xA0111623),
          activeCardTextColor: Color(0xFFEFF3FF),
          inactiveTextColor: Color(0xB3D2DAF3),
          passedInactiveTextColor: Color(0x66C7D0EA),
          coneColor: Color(0xFFFFE6A8),
          coneIntensity: 1.0,
          particleColor: Color(0xFFFFFFFF),
          particleCount: 72,
          particleMinRadius: 0.4,
          particleMaxRadius: 1.9,
          particleMaxOpacity: 0.58,
          particleStyle: _ParticleStyle.starfield,
        );
      case _ThemePhase.dawnFajr:
        return const _PhasePalette(
          backgroundColors: <Color>[
            Color(0xFF0D1332),
            Color(0xFF30204E),
            Color(0xFF6C4456),
          ],
          accentColor: Color(0xFFFFD98F),
          primaryTextColor: Color(0xFFEFF3FF),
          topMetaColor: Color(0xFFCFD7F0),
          chipBackground: Color(0x20FFFFFF),
          chipBorder: Color(0x2DFFFFFF),
          bottomDateColor: Color(0xDCE6D4A3),
          bottomMetaColor: Color(0x66FFFFFF),
          listOverlayColor: Color(0xBB140B17),
          activeCardColor: Color(0xA31F1D2A),
          activeCardTextColor: Color(0xFFEFF3FF),
          inactiveTextColor: Color(0xB3D2DAF3),
          passedInactiveTextColor: Color(0x66C7D0EA),
          coneColor: Color(0xFFFFCF8A),
          coneIntensity: 1.0,
          particleColor: Color(0xFFFFE8C4),
          particleCount: 66,
          particleMinRadius: 0.5,
          particleMaxRadius: 2.0,
          particleMaxOpacity: 0.54,
          particleStyle: _ParticleStyle.starfield,
        );
      case _ThemePhase.dawnMaghrib:
        return const _PhasePalette(
          backgroundColors: <Color>[
            Color(0xFF2B1028),
            Color(0xFF3D1E4A),
            Color(0xFF13213F),
          ],
          accentColor: Color(0xFFFFC88B),
          primaryTextColor: Color(0xFFF8EEE7),
          topMetaColor: Color(0xFFEAD8C8),
          chipBackground: Color(0x20FFFFFF),
          chipBorder: Color(0x2DFFFFFF),
          bottomDateColor: Color(0xE6F4D09C),
          bottomMetaColor: Color(0x99FFFFFF),
          listOverlayColor: Color(0xBB140B19),
          activeCardColor: Color(0xA3271D30),
          activeCardTextColor: Color(0xFFF8EFE8),
          inactiveTextColor: Color(0xD9F0DCCB),
          passedInactiveTextColor: Color(0x88E1CEBF),
          coneColor: Color(0xFFFFBD72),
          coneIntensity: 0.95,
          particleColor: Color(0xFFFFE3BE),
          particleCount: 58,
          particleMinRadius: 0.45,
          particleMaxRadius: 1.8,
          particleMaxOpacity: 0.5,
          particleStyle: _ParticleStyle.starfield,
        );
      case _ThemePhase.day:
        return const _PhasePalette(
          backgroundColors: <Color>[
            Color(0xFFB9883D),
            Color(0xFFD1A75F),
            Color(0xFFE5BF7A),
          ],
          backgroundStops: <double>[0.0, 0.58, 1.0],
          accentColor: Color(0xFFA66722),
          primaryTextColor: Color(0xFF14233D),
          topMetaColor: Color(0xFF5A3C1D),
          chipBackground: Color(0x52F1DDAC),
          chipBorder: Color(0xA9D9AB50),
          bottomDateColor: Color(0xCC5A3F20),
          bottomMetaColor: Color(0xAA5D4225),
          listOverlayColor: Color(0x885A3F20),
          activeCardColor: Color(0xBEEAD2A2),
          activeCardTextColor: Color(0xFF14233D),
          inactiveTextColor: Color(0xCC4E371B),
          passedInactiveTextColor: Color(0x91553C20),
          coneColor: Color(0xFFFFF8E8),
          coneIntensity: 1.08,
          particleColor: Color(0xFFFFE6A0),
          particleCount: 68,
          particleMinRadius: 0.45,
          particleMaxRadius: 1.7,
          particleMaxOpacity: 0.24,
          particleStyle: _ParticleStyle.dust,
          showPattern: true,
          patternOpacity: 0.52,
          patternColor: Color(0x66F7E18D),
          titleShadowOpacity: 0.1,
        );
    }
  }

  String _durationText(Duration d) {
    final safe = d.isNegative ? Duration.zero : d;
    final h = safe.inHours;
    final m = safe.inMinutes.remainder(60);
    final s = safe.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double _phaseProgress({
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final totalSeconds = end.difference(start).inSeconds;
    if (totalSeconds <= 0) {
      return 1;
    }
    final elapsed = now.difference(start).inSeconds;
    final ratio = elapsed / totalSeconds;
    return ratio.clamp(0.0, 1.0);
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

  String _displayPrayerName(BuildContext context, PrayerType type, DateTime now, bool isRamadan) {
    final l = AppLocalizations.of(context)!;
    if (type == PrayerType.dhuhr && now.weekday == DateTime.friday) return l.prayerJumuah;
    if (type == PrayerType.maghrib && isRamadan) return l.prayerIftar;
    if (type == PrayerType.fajr && isRamadan) return l.prayerSuhoor;
    return _localizedPrayerName(context, type);
  }

  String _arabicByPrayer(PrayerType type, DateTime now) {
    switch (type) {
      case PrayerType.fajr:
        return 'فجر';
      case PrayerType.sunrise:
        return 'شروق';
      case PrayerType.dhuhr:
        return now.weekday == DateTime.friday ? 'جمعة' : 'ظهر';
      case PrayerType.asr:
        return 'عصر';
      case PrayerType.maghrib:
        return 'مغرب';
      case PrayerType.isha:
        return 'عشاء';
    }
  }

  IconData _iconByPrayer(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.wb_twilight_rounded;
      case PrayerType.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr:
        return Icons.sunny;
      case PrayerType.asr:
        return Icons.light_mode_outlined;
      case PrayerType.maghrib:
        return Icons.brightness_3_outlined;
      case PrayerType.isha:
        return Icons.nightlight_round;
    }
  }
}

class _ActivePrayerCard extends StatelessWidget {
  const _ActivePrayerCard({
    required this.prayerName,
    required this.prayerArabic,
    required this.time,
    required this.nextInfo,
    required this.icon,
    required this.palette,
  });

  final String prayerName;
  final String prayerArabic;
  final String time;
  final String nextInfo;
  final IconData icon;
  final _PhasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: palette.activeCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: palette.accentColor.withValues(alpha: 0.74),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.accentColor.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: palette.accentColor, size: 30),
                    Column(
                      children: [
                        Text(
                          prayerArabic,
                          style: GoogleFonts.amiri(
                            fontSize: 30,
                            color: palette.activeCardTextColor,
                            height: 1,
                          ),
                        ),
                        Text(
                          prayerName.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            fontSize: 30,
                            color: palette.accentColor,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    color: palette.activeCardTextColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: palette.chipBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    nextInfo,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: palette.activeCardTextColor.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RamadanHangingDecor extends StatelessWidget {
  const _RamadanHangingDecor({
    required this.animationValue,
    required this.accentColor,
    required this.ornaments,
  });

  final double animationValue;
  final Color accentColor;
  final List<_OrnamentConfig> ornaments;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.45 + (0.3 * math.sin(animationValue * math.pi * 2));

    return SizedBox(
      height: 174,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: ornaments.map((item) {
              final x = (constraints.maxWidth * item.xFactor) - (item.iconSize);
              return Positioned(
                left: x,
                top: 0,
                child: _HangingOrnament(
                  icon: item.icon,
                  accentColor: accentColor,
                  pulse: pulse,
                  lineHeight: item.lineHeight,
                  iconSize: item.iconSize,
                  onTap: item.onTap,
                  tooltip: item.tooltip,
                  animationValue: animationValue,
                  phaseShift: item.phaseShift,
                  motionAmplitude: item.motionAmplitude,
                  speedFactor: item.speedFactor,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _OrnamentConfig {
  const _OrnamentConfig({
    required this.xFactor,
    required this.lineHeight,
    required this.iconSize,
    required this.icon,
    required this.phaseShift,
    required this.motionAmplitude,
    required this.speedFactor,
    this.onTap,
    this.tooltip,
  });

  final double xFactor;
  final double lineHeight;
  final double iconSize;
  final IconData icon;
  final double phaseShift;
  final double motionAmplitude;
  final double speedFactor;
  final VoidCallback? onTap;
  final String? tooltip;
}

class _HangingOrnament extends StatelessWidget {
  const _HangingOrnament({
    required this.icon,
    required this.accentColor,
    required this.pulse,
    required this.iconSize,
    required this.lineHeight,
    required this.animationValue,
    required this.phaseShift,
    required this.motionAmplitude,
    required this.speedFactor,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final Color accentColor;
  final double pulse;
  final double iconSize;
  final double lineHeight;
  final double animationValue;
  final double phaseShift;
  final double motionAmplitude;
  final double speedFactor;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final sweep = _continuousSweep((animationValue * speedFactor) + phaseShift);
    final animatedLineHeight = (lineHeight + (sweep * motionAmplitude)).clamp(
      36.0,
      180.0,
    );

    final iconWidget = Icon(
      icon,
      size: iconSize,
      color: accentColor.withValues(alpha: 0.78 + pulse * 0.2),
      shadows: [
        Shadow(
          color: accentColor.withValues(alpha: 0.26 + pulse * 0.22),
          blurRadius: 10 + pulse * 5,
        ),
      ],
    );

    final hangingBody = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 1.1,
          height: animatedLineHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.5),
                accentColor.withValues(alpha: 0.16 + pulse * 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 4),
        iconWidget,
      ],
    );

    final interactive = onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: hangingBody,
            ),
          )
        : hangingBody;

    if (tooltip == null) {
      return interactive;
    }
    return Tooltip(message: tooltip!, child: interactive);
  }

  double _continuousSweep(double t) {
    final v = t % 1.0;
    if (v < 0.5) {
      return (v * 4) - 1;
    }
    return 3 - (v * 4);
  }
}

class _InactivePrayerRow extends StatelessWidget {
  const _InactivePrayerRow({
    required this.prayerName,
    required this.time,
    required this.icon,
    required this.faded,
    required this.textColor,
    this.fadedOpacity = 0.55,
  });

  final String prayerName;
  final String time;
  final IconData icon;
  final bool faded;
  final Color textColor;
  final double fadedOpacity;

  @override
  Widget build(BuildContext context) {
    final color = faded ? textColor.withValues(alpha: fadedOpacity) : textColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(
                prayerName.toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: color,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: GoogleFonts.manrope(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.animationValue,
    required this.count,
    required this.color,
    required this.minRadius,
    required this.maxRadius,
    required this.maxOpacity,
    required this.style,
  });

  final double animationValue;
  final int count;
  final Color color;
  final double minRadius;
  final double maxRadius;
  final double maxOpacity;
  final _ParticleStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final ySeed = random.nextDouble();
      final speed = style == _ParticleStyle.starfield
          ? 0.08 + random.nextDouble() * 0.22
          : 0.01 + random.nextDouble() * 0.03;
      final radius = minRadius + random.nextDouble() * (maxRadius - minRadius);
      final alphaBase = style == _ParticleStyle.starfield ? 0.12 : 0.06;
      final alpha = alphaBase + random.nextDouble() * maxOpacity;

      var y = ySeed;
      var xShift = 0.0;
      if (style == _ParticleStyle.starfield) {
        y = (ySeed - animationValue * speed) % 1.0;
        if (y < 0) {
          y += 1.0;
        }
      } else {
        y = (ySeed + animationValue * speed) % 1.0;
        xShift = math.sin((animationValue * math.pi * 2) + i) * 12.0;
      }

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x + xShift, y * size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.count != count ||
        oldDelegate.color != color ||
        oldDelegate.style != style;
  }
}

class _SacredPatternPainter extends CustomPainter {
  const _SacredPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const gap = 72.0;
    const r = 22.0;
    for (double y = -gap; y < size.height + gap; y += gap) {
      for (double x = -gap; x < size.width + gap; x += gap) {
        final center = Offset(x, y);
        canvas.drawCircle(center, r, paint);
        canvas.drawCircle(
          center,
          r * 2,
          paint..color = color.withValues(alpha: 0.4),
        );
        paint.color = color;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SacredPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _LightConePainter extends CustomPainter {
  const _LightConePainter({
    required this.color,
    required this.intensity,
    required this.isDayTime,
  });

  final Color color;
  final double intensity;
  final bool isDayTime;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height * 1.5;

    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..style = PaintingStyle.fill;

    _drawBeam(
      canvas,
      topCenter: Offset(centerX, -20),
      bottomCenter: Offset(centerX, bottomY),
      topWidth: 60,
      bottomWidth: 380,
      color: isDayTime
          ? Colors.white.withValues(alpha: 0.18)
          : color.withValues(alpha: 0.25 * intensity),
      paint: paint,
    );

    _drawBeam(
      canvas,
      topCenter: Offset(centerX - 15, -20),
      bottomCenter: Offset(centerX - 80, bottomY * 0.8),
      topWidth: 20,
      bottomWidth: 60,
      color: isDayTime
          ? Colors.white.withValues(alpha: 0.10)
          : color.withValues(alpha: 0.10 * intensity),
      paint: paint,
    );

    _drawBeam(
      canvas,
      topCenter: Offset(centerX + 15, -20),
      bottomCenter: Offset(centerX + 80, bottomY * 0.85),
      topWidth: 25,
      bottomWidth: 70,
      color: isDayTime
          ? Colors.white.withValues(alpha: 0.11)
          : color.withValues(alpha: 0.12 * intensity),
      paint: paint,
    );

    _drawBeam(
      canvas,
      topCenter: Offset(centerX, -50),
      bottomCenter: Offset(centerX, size.height * 0.6),
      topWidth: size.width * 0.4,
      bottomWidth: size.width * 0.8,
      color: isDayTime
          ? Colors.white.withValues(alpha: 0.05)
          : color.withValues(alpha: 0.05 * intensity),
      paint: Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  void _drawBeam(
    Canvas canvas, {
    required Offset topCenter,
    required Offset bottomCenter,
    required double topWidth,
    required double bottomWidth,
    required Color color,
    required Paint paint,
  }) {
    final path = Path()
      ..moveTo(topCenter.dx - topWidth / 2, topCenter.dy)
      ..lineTo(topCenter.dx + topWidth / 2, topCenter.dy)
      ..lineTo(bottomCenter.dx + bottomWidth / 2, bottomCenter.dy)
      ..lineTo(bottomCenter.dx - bottomWidth / 2, bottomCenter.dy)
      ..close();

    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDayTime
          ? <Color>[
              Colors.white.withValues(alpha: 0.34),
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
            ]
          : <Color>[color, color.withValues(alpha: 0.10), Colors.transparent],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(path.getBounds());

    paint.shader = shader;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LightConePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.intensity != intensity ||
        oldDelegate.isDayTime != isDayTime;
  }
}

class _SlimDownArrowPainter extends CustomPainter {
  const _SlimDownArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final centerX = size.width / 2;
    final top = 2.0;
    final neckBottom = size.height - 10;
    final tipY = size.height - 3;

    canvas.drawLine(
      Offset(centerX, top),
      Offset(centerX, neckBottom),
      glowPaint,
    );
    canvas.drawLine(
      Offset(centerX, top),
      Offset(centerX, neckBottom),
      linePaint,
    );

    final chevron = Path()
      ..moveTo(centerX - 4.5, neckBottom - 2)
      ..lineTo(centerX, tipY)
      ..lineTo(centerX + 4.5, neckBottom - 2);

    canvas.drawPath(chevron, glowPaint);
    canvas.drawPath(chevron, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SlimDownArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ThinChevronDownPainter extends CustomPainter {
  const _ThinChevronDownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(1.6, size.height * 0.36)
      ..lineTo(size.width / 2, size.height - 1.6)
      ..lineTo(size.width - 1.6, size.height * 0.36);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ThinChevronDownPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PrayerEntry {
  const _PrayerEntry(this.type, this.time);

  final PrayerType type;
  final DateTime time;
}

class _TimingModel {
  const _TimingModel({
    required this.activePrayer,
    required this.activePrayerTime,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.timeUntilNext,
  });

  final PrayerType activePrayer;
  final DateTime activePrayerTime;
  final PrayerType nextPrayer;
  final DateTime nextPrayerTime;
  final Duration timeUntilNext;
}

enum _ThemePhase { night, dawnFajr, dawnMaghrib, day }

enum _ParticleStyle { starfield, dust }

class _PhasePalette {
  const _PhasePalette({
    required this.backgroundColors,
    this.backgroundStops,
    required this.accentColor,
    required this.primaryTextColor,
    required this.topMetaColor,
    required this.chipBackground,
    required this.chipBorder,
    required this.bottomDateColor,
    required this.bottomMetaColor,
    required this.listOverlayColor,
    required this.activeCardColor,
    required this.activeCardTextColor,
    required this.inactiveTextColor,
    required this.passedInactiveTextColor,
    required this.coneColor,
    required this.coneIntensity,
    required this.particleColor,
    required this.particleCount,
    required this.particleMinRadius,
    required this.particleMaxRadius,
    required this.particleMaxOpacity,
    required this.particleStyle,
    this.showPattern = false,
    this.patternOpacity = 0.0,
    this.patternColor = Colors.transparent,
    this.titleShadowOpacity = 0.0,
  });

  final List<Color> backgroundColors;
  final List<double>? backgroundStops;
  final Color accentColor;
  final Color primaryTextColor;
  final Color topMetaColor;
  final Color chipBackground;
  final Color chipBorder;
  final Color bottomDateColor;
  final Color bottomMetaColor;
  final Color listOverlayColor;
  final Color activeCardColor;
  final Color activeCardTextColor;
  final Color inactiveTextColor;
  final Color passedInactiveTextColor;
  final Color coneColor;
  final double coneIntensity;
  final Color particleColor;
  final int particleCount;
  final double particleMinRadius;
  final double particleMaxRadius;
  final double particleMaxOpacity;
  final _ParticleStyle particleStyle;
  final bool showPattern;
  final double patternOpacity;
  final Color patternColor;
  final double titleShadowOpacity;
}
