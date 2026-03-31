import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../providers/location_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  bool _permissionGranted = false;
  bool _serviceEnabled = false;
  bool _sensorSupported = true;
  bool _statusChecked = false;
  double _qiblaNeedleAngleRad = 0; // for light cone rotation

  void updateQiblaAngle(double angleRad) {
    if (_qiblaNeedleAngleRad != angleRad) {
      setState(() => _qiblaNeedleAngleRad = angleRad);
    }
  }
  late final AnimationController _glowController;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat(); // no reverse - always forward
    _checkStatus();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (!_isMobile()) {
      setState(() => _statusChecked = true);
      return;
    }
    try {
      final sensorSupport = await FlutterQiblah.androidDeviceSensorSupport();
      final locationStatus = await FlutterQiblah.checkLocationStatus();
      var permission = locationStatus.status;
      if (permission == LocationPermission.denied) {
        permission = await FlutterQiblah.requestPermissions();
      }
      if (!mounted) return;
      setState(() {
        _sensorSupported = sensorSupport ?? true;
        _serviceEnabled = locationStatus.enabled;
        _permissionGranted =
            permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse;
        _statusChecked = true;
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _sensorSupported = false;
        _statusChecked = true;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _sensorSupported = false;
        _statusChecked = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sensorSupported = false;
        _statusChecked = true;
      });
    }
  }

  bool _isMobile() {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final l = AppLocalizations.of(context)!;
    const palette = _QiblaPalette(
      backgroundColors: [Color(0xFF02030A), Color(0xFF071330), Color(0xFF02030A)],
      backgroundStops: [0.0, 0.55, 1.0],
      accentColor: Color(0xFFFFD98F),
      primaryText: Color(0xFFEFF3FF),
      secondaryText: Color(0xB3D2DAF3),
      compassRingColor: Color(0xFFFFD98F),
      compassBgColor: Color(0xFF0A1428),
      compassTickColor: Color(0xCCFFD98F),
      compassNumberColor: Color(0xB3FFD98F),
      needleColor: Color(0xFFFFD98F),
      skylineColor: Color(0x33FFD98F),
      coneColor: Color(0xFFFFE6A8),
      isDark: true,
    );
    final cityName = locationProvider.location?.cityName ?? '';

    return Scaffold(
      backgroundColor: palette.backgroundColors.first,
      body: Stack(
        children: [
          // Background gradient
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
          // Particles
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _QiblaParticlePainter(
                      animationValue: _particleController.value,
                      color: palette.accentColor,
                    ),
                  );
                },
              ),
            ),
          ),
          // Light beam (full-screen, not clipped by compass SizedBox)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.rotate(
                angle: _qiblaNeedleAngleRad,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _QiblaBeamPainter(color: palette.coneColor),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back, color: palette.accentColor),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.location_on_outlined,
                          color: palette.accentColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        l.qibla,
                        style: GoogleFonts.cinzel(
                          color: palette.accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      if (cityName.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on,
                                color: palette.secondaryText, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              cityName,
                              style: GoogleFonts.manrope(
                                color: palette.secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
                // Main compass area
                Expanded(
                  child: _buildCompassBody(palette, l),
                ),
                // Back button
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _PremiumBackButton(
                    palette: palette,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassBody(_QiblaPalette palette, AppLocalizations l) {
    if (!_statusChecked) {
      return Center(
        child: CircularProgressIndicator(color: palette.accentColor),
      );
    }

    if (!_isMobile() || !_sensorSupported) {
      return _ErrorState(
        message: l.compassNotAvailable,
        palette: palette,
        icon: Icons.explore_off,
      );
    }

    if (!_permissionGranted || !_serviceEnabled) {
      return _ErrorState(
        message: l.locationRequiredForQibla,
        palette: palette,
        icon: Icons.location_off,
        onRetry: () async {
          await _checkStatus();
          if (!_permissionGranted) {
            await Geolocator.openAppSettings();
          } else if (!_serviceEnabled) {
            await Geolocator.openLocationSettings();
          }
        },
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        // If waiting too long (simulator has no sensor), show static qibla
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _StaticQiblaFallback(
            palette: palette,
            l: l,
            glowController: _glowController,
          );
        }

        if (!snapshot.hasData) {
          return _StaticQiblaFallback(
            palette: palette,
            l: l,
            glowController: _glowController,
          );
        }

        final data = snapshot.data!;
        final qiblaAngle = data.qiblah;
        final direction = data.direction;
        final compassRotation = -direction * (math.pi / 180);
        // Same formula as mini compass: qiblah is already relative to device
        final qiblaNeedleRotation = qiblaAngle * (math.pi / 180) * -1;

        // Update light cone direction
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _qiblaNeedleAngleRad != qiblaNeedleRotation) {
            setState(() => _qiblaNeedleAngleRad = qiblaNeedleRotation);
          }
        });
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Compass
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glowIntensity =
                    0.15 + (_glowController.value * 0.15);
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: palette.accentColor
                            .withValues(alpha: glowIntensity),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // 1. Compass dial
                    Transform.rotate(
                      angle: compassRotation,
                      child: CustomPaint(
                        size: const Size(300, 300),
                        painter: _CompassDialPainter(palette: palette),
                      ),
                    ),
                    // 2. Green Qibla needle + Kaaba at tip
                    Transform.rotate(
                      angle: qiblaNeedleRotation,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(300, 300),
                              painter: _QiblaNeedlePainter(),
                            ),
                            // Kaaba icon at the tip of the needle
                            Positioned(
                              top: 6,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2E7D32),
                                  border: Border.all(
                                    color: const Color(0xFF81C784),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  FlutterIslamicIcons.solidQibla,
                                  color: Color(0xFFFFD98F),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Center dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.compassBgColor,
                        border: Border.all(
                          color: palette.compassRingColor.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        );
      },
    );
  }
}

// ─── Palette ──────────────────────────────────────

class _QiblaPalette {
  const _QiblaPalette({
    required this.backgroundColors,
    required this.backgroundStops,
    required this.accentColor,
    required this.primaryText,
    required this.secondaryText,
    required this.compassRingColor,
    required this.compassBgColor,
    required this.compassTickColor,
    required this.compassNumberColor,
    required this.needleColor,
    required this.skylineColor,
    required this.coneColor,
    required this.isDark,
  });

  final List<Color> backgroundColors;
  final List<double> backgroundStops;
  final Color accentColor;
  final Color primaryText;
  final Color secondaryText;
  final Color compassRingColor;
  final Color compassBgColor;
  final Color compassTickColor;
  final Color compassNumberColor;
  final Color needleColor;
  final Color skylineColor;
  final Color coneColor;
  final bool isDark;
}

// ─── Compass Dial Painter ─────────────────────────

class _CompassDialPainter extends CustomPainter {
  const _CompassDialPainter({required this.palette});

  final _QiblaPalette palette;

  // Premium gold tones
  static const _goldDark = Color(0xFFB8860B);
  static const _goldMid = Color(0xFFD4AF37);
  static const _goldLight = Color(0xFFFFD98F);
  static const _goldBright = Color(0xFFFFE6A8);
  static const _goldShadow = Color(0xFF8B6914);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Premium outer bezel (thick gold band) ──
    // Outer shadow ring
    final outerShadowPaint = Paint()
      ..color = _goldShadow.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius - 8, outerShadowPaint);

    // Main gold bezel ring with sweep gradient
    final bezelPaint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [_goldDark, _goldLight, _goldBright, _goldMid, _goldDark, _goldLight, _goldDark],
        [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(center, radius - 8, bezelPaint);

    // Bright highlight line on top edge
    final highlightPaint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        [
          _goldBright.withValues(alpha: 0.0),
          _goldBright.withValues(alpha: 0.7),
          _goldBright.withValues(alpha: 0.0),
        ],
        [0.2, 0.35, 0.5],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 1.5, highlightPaint);

    // Inner edge of bezel
    final bezelInnerPaint = Paint()
      ..color = _goldShadow.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius - 15, bezelInnerPaint);

    // Outer bright edge
    final bezelOuterPaint = Paint()
      ..color = _goldBright.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 1, bezelOuterPaint);

    // ── Ornamental pattern in bezel (small notches) ──
    for (int i = 0; i < 72; i++) {
      final angleRad = i * 5 * math.pi / 180;
      final notchOuter = radius - 3;
      final notchInner = radius - 13;
      final outerPt = Offset(
        center.dx + notchOuter * math.sin(angleRad),
        center.dy - notchOuter * math.cos(angleRad),
      );
      final innerPt = Offset(
        center.dx + notchInner * math.sin(angleRad),
        center.dy - notchInner * math.cos(angleRad),
      );
      final notchPaint = Paint()
        ..color = _goldShadow.withValues(alpha: 0.35)
        ..strokeWidth = 0.7
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(innerPt, outerPt, notchPaint);
    }

    // ── Inner ring (separator) ──
    final innerRingPaint = Paint()
      ..color = _goldMid.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 18, innerRingPaint);

    // Background fill
    final bgPaint = Paint()
      ..color = palette.compassBgColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 19, bgPaint);

    // Tick marks and numbers
    for (int i = 0; i < 360; i += 5) {
      final angleRad = i * math.pi / 180;
      final isMajor = i % 15 == 0;
      final isCardinal = i % 90 == 0;

      final outerR = radius - 20;
      final innerR = isMajor ? radius - 36 : radius - 28;

      final outerPoint = Offset(
        center.dx + outerR * math.sin(angleRad),
        center.dy - outerR * math.cos(angleRad),
      );
      final innerPoint = Offset(
        center.dx + innerR * math.sin(angleRad),
        center.dy - innerR * math.cos(angleRad),
      );

      final tickPaint = Paint()
        ..color = isCardinal
            ? palette.compassTickColor
            : palette.compassTickColor.withValues(alpha: isMajor ? 0.7 : 0.35)
        ..strokeWidth = isCardinal ? 2.5 : (isMajor ? 1.5 : 0.8)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(innerPoint, outerPoint, tickPaint);

      // Draw numbers every 15 degrees
      if (isMajor) {
        final textRadius = radius - 46;
        final textCenter = Offset(
          center.dx + textRadius * math.sin(angleRad),
          center.dy - textRadius * math.cos(angleRad),
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(
              color: isCardinal
                  ? palette.compassNumberColor
                  : palette.compassNumberColor.withValues(alpha: 0.65),
              fontSize: isCardinal ? 13 : 10,
              fontWeight: isCardinal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();

        canvas.save();
        canvas.translate(textCenter.dx, textCenter.dy);
        canvas.rotate(angleRad);
        canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }

    // N / S / E / W markers
    const cardinals = ['N', 'E', 'S', 'W'];
    const cardinalAngles = [0.0, 90.0, 180.0, 270.0];
    for (int i = 0; i < 4; i++) {
      final angleRad = cardinalAngles[i] * math.pi / 180;
      final markerRadius = radius - 62;
      final pos = Offset(
        center.dx + markerRadius * math.sin(angleRad),
        center.dy - markerRadius * math.cos(angleRad),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: cardinals[i],
          style: TextStyle(
            color: i == 0
                ? palette.needleColor
                : palette.compassNumberColor.withValues(alpha: 0.5),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      tp.layout();
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angleRad);
      canvas.translate(-tp.width / 2, -tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter old) =>
      old.palette != palette;
}

// ─── Qibla Needle Painter ─────────────────────────

class _QiblaNeedlePainter extends CustomPainter {
  const _QiblaNeedlePainter();

  static const _qiblaGreenDark = Color(0xFF1B5E20);
  static const _qiblaGreen = Color(0xFF388E3C);
  static const _qiblaGreenLight = Color(0xFF66BB6A);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Needle dimensions - thick and bold
    final tipY = center.dy - (radius - 30); // leave room for Kaaba circle
    final baseY = center.dy - 10;
    const needleWidth = 22.0;

    // Main arrow body: wide tapered shape from center to tip
    final needlePath = Path()
      ..moveTo(center.dx, tipY) // tip
      ..lineTo(center.dx - needleWidth / 2, baseY) // left base
      ..quadraticBezierTo(center.dx, baseY + 6, // smooth bottom
          center.dx + needleWidth / 2, baseY) // right base
      ..close();

    // Outer glow
    final glowPaint = Paint()
      ..color = _qiblaGreen.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(needlePath, glowPaint);

    // Main fill with gradient
    final needlePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx, tipY),
        Offset(center.dx, baseY),
        [_qiblaGreenLight, _qiblaGreenDark],
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePath, needlePaint);

    // Highlight stroke on left edge
    final edgePaint = Paint()
      ..color = _qiblaGreenLight.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(needlePath, edgePaint);

    // Opposite tail (subtle, thinner)
    final tailPath = Path()
      ..moveTo(center.dx, center.dy + 10)
      ..lineTo(center.dx - 6, center.dy + radius * 0.45)
      ..quadraticBezierTo(center.dx, center.dy + radius * 0.48,
          center.dx + 6, center.dy + radius * 0.45)
      ..close();

    final tailPaint = Paint()
      ..color = _qiblaGreen.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tailPath, tailPaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter old) => false;
}

// ─── Qibla Beam Painter (light from Kaaba toward compass) ─────

/// Triangular light beam: narrow at compass center, widens toward Kaaba.
/// Drawn pointing UP; Transform.rotate aligns it with qibla direction.
class _QiblaBeamPainter extends CustomPainter {
  const _QiblaBeamPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2;

    // Use radial gradient from center — rotation-invariant
    // Draw an arc sector (pie slice) pointing UP, then let Transform.rotate aim it

    // Beam extends from center to well beyond the compass edge
    final beamRadius = radius * 4; // long reach
    const halfAngle = 0.28; // half-spread in radians (~16° each side = 32° total)

    // Sector path: pie slice from center going UP
    final outerPath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - beamRadius * math.sin(halfAngle), cy - beamRadius * math.cos(halfAngle))
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: beamRadius),
        -math.pi / 2 - halfAngle, // start angle (from 3 o'clock, so -90° minus spread)
        halfAngle * 2, // sweep
        false,
      )
      ..close();

    // Radial gradient: bright at center, fades outward — works perfectly with rotation
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        beamRadius,
        [
          color.withValues(alpha: 0.55),
          color.withValues(alpha: 0.30),
          color.withValues(alpha: 0.12),
          color.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        const [0.0, 0.08, 0.2, 0.45, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);
    canvas.drawPath(outerPath, glowPaint);
    canvas.drawPath(outerPath, glowPaint); // double pass

    // Core beam — narrower, brighter
    final coreRadius = radius * 3;
    const coreHalfAngle = 0.12;
    final corePath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - coreRadius * math.sin(coreHalfAngle), cy - coreRadius * math.cos(coreHalfAngle))
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: coreRadius),
        -math.pi / 2 - coreHalfAngle,
        coreHalfAngle * 2,
        false,
      )
      ..close();

    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        coreRadius,
        [
          color.withValues(alpha: 0.45),
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        const [0.0, 0.1, 0.35, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawPath(corePath, corePaint);

    // Center spine line
    final linePaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        radius * 2,
        [color.withValues(alpha: 0.50), Colors.transparent],
        const [0.0, 1.0],
      )
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - radius * 2), linePaint);

    // ── Tail beam (opposite direction — downward) ──
    // Softer, narrower glow extending behind the compass
    final tailRadius = radius * 2.5;
    const tailHalfAngle = 0.20;
    final tailPath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - tailRadius * math.sin(tailHalfAngle), cy + tailRadius * math.cos(tailHalfAngle))
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: tailRadius),
        math.pi / 2 - tailHalfAngle, // start angle pointing DOWN
        tailHalfAngle * 2,
        false,
      )
      ..close();

    final tailPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        tailRadius,
        [
          color.withValues(alpha: 0.20),
          color.withValues(alpha: 0.08),
          color.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        const [0.0, 0.1, 0.3, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawPath(tailPath, tailPaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaBeamPainter old) => old.color != color;
}

// ─── Particles ────────────────────────────────────

class _QiblaParticlePainter extends CustomPainter {
  const _QiblaParticlePainter({
    required this.animationValue,
    required this.color,
  });

  final double animationValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < 70; i++) {
      final x = random.nextDouble() * size.width;
      final ySeed = random.nextDouble();
      final speed = 0.08 + random.nextDouble() * 0.22;
      final radius = 0.4 + random.nextDouble() * 1.9;
      final alpha = 0.12 + random.nextDouble() * 0.58;

      var y = (ySeed - animationValue * speed) % 1.0;
      if (y < 0) y += 1.0;

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y * size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _QiblaParticlePainter old) =>
      old.animationValue != animationValue;
}


// ─── Static Qibla Fallback (Simulator / No Sensor Stream) ─────

class _StaticQiblaFallback extends StatelessWidget {
  const _StaticQiblaFallback({
    required this.palette,
    required this.l,
    required this.glowController,
  });

  final _QiblaPalette palette;
  final AppLocalizations l;
  final AnimationController glowController;

  @override
  Widget build(BuildContext context) {
    final location = context.read<LocationProvider>().location;
    if (location == null) {
      return _ErrorState(
        message: l.locationRequiredForQibla,
        palette: palette,
        icon: Icons.location_off,
      );
    }

    // Calculate static qibla angle using adhan package
    final coordinates = adhan.Coordinates(location.latitude, location.longitude);
    final qibla = adhan.Qibla(coordinates);
    final qiblaAngle = qibla.direction;
    final qiblaAngleRad = qiblaAngle * (math.pi / 180);

    // Update parent's light cone direction immediately
    final state = context.findAncestorStateOfType<_QiblaScreenState>();
    if (state != null && state._qiblaNeedleAngleRad != qiblaAngleRad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.mounted) {
          state.updateQiblaAngle(qiblaAngleRad);
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        AnimatedBuilder(
          animation: glowController,
          builder: (context, child) {
            final glowIntensity = 0.15 + (glowController.value * 0.15);
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.accentColor.withValues(alpha: glowIntensity),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // 1. Static compass dial
                CustomPaint(
                  size: const Size(300, 300),
                  painter: _CompassDialPainter(palette: palette),
                ),
                // 2. Green needle + Kaaba at tip (static)
                Transform.rotate(
                  angle: qiblaAngle * (math.pi / 180),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const CustomPaint(
                          size: Size(300, 300),
                          painter: _QiblaNeedlePainter(),
                        ),
                        Positioned(
                          top: 6,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2E7D32),
                              border: Border.all(
                                color: const Color(0xFF81C784),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              FlutterIslamicIcons.solidQibla,
                              color: Color(0xFFFFD98F),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Center dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.compassBgColor,
                    border: Border.all(
                      color: palette.compassRingColor.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}

// ─── Error State ──────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.palette,
    required this.icon,
    this.onRetry,
  });

  final String message;
  final _QiblaPalette palette;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: palette.secondaryText, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: palette.secondaryText,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.accentColor,
                  side: BorderSide(
                    color: palette.accentColor.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Premium Back Button ──────────────────────────

class _PremiumBackButton extends StatelessWidget {
  const _PremiumBackButton({
    required this.palette,
    required this.onTap,
  });

  final _QiblaPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: palette.isDark
              ? palette.accentColor.withValues(alpha: 0.15)
              : palette.accentColor.withValues(alpha: 0.2),
          border: Border.all(
            color: palette.accentColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: palette.accentColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}