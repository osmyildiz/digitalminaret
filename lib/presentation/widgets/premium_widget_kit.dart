import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kGoldColor = Color(0xFFFFD98F);
const Color kDarkGlassColor = Color(0xFF111623);

class DigitalMinaretLogo extends StatelessWidget {
  const DigitalMinaretLogo({
    super.key,
    this.size = 100,
    this.color = kGoldColor,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MinaretLogoPainter(color: color)),
    );
  }
}

class _MinaretLogoPainter extends CustomPainter {
  _MinaretLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path();
    final baseWidth = w * 0.3;
    final baseTop = h * 0.6;
    path.moveTo(cx - baseWidth / 2, h * 0.95);
    path.lineTo(cx - baseWidth / 2, baseTop);
    path.quadraticBezierTo(
      cx - baseWidth * 0.6,
      baseTop - (h * 0.05),
      cx - baseWidth * 0.4,
      baseTop - (h * 0.1),
    );
    final bodyWidth = w * 0.22;
    final bodyBottom = baseTop - (h * 0.1);
    final domeStart = h * 0.25;
    path.lineTo(cx - bodyWidth / 2, domeStart);
    path.quadraticBezierTo(cx - bodyWidth * 0.6, h * 0.15, cx, h * 0.05);
    path.quadraticBezierTo(
      cx + bodyWidth * 0.6,
      h * 0.15,
      cx + bodyWidth / 2,
      domeStart,
    );
    path.lineTo(cx + bodyWidth / 2, bodyBottom);
    path.quadraticBezierTo(
      cx + baseWidth * 0.6,
      baseTop - (h * 0.05),
      cx + baseWidth / 2,
      baseTop,
    );
    path.lineTo(cx + baseWidth / 2, h * 0.95);
    path.moveTo(cx - baseWidth / 3, h * 0.95);
    path.quadraticBezierTo(cx, h * 0.85, cx + baseWidth / 3, h * 0.95);

    final moonCenter = Offset(cx, h * 0.45);
    final moonRadius = w * 0.08;
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final cutCircle = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(
            moonCenter.dx + (moonRadius * 0.4),
            moonCenter.dy - (moonRadius * 0.1),
          ),
          radius: moonRadius * 0.9,
        ),
      );
    final crescent = Path.combine(
      PathOperation.difference,
      moonPath,
      cutCircle,
    );

    final beamPath = Path()
      ..moveTo(cx - (w * 0.4), 0)
      ..lineTo(cx + (w * 0.4), 0)
      ..lineTo(cx + (w * 0.15), h * 0.4)
      ..lineTo(cx - (w * 0.15), h * 0.4)
      ..close();
    final beamShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    final beamPaint = Paint()
      ..shader = beamShader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(beamPath, beamPaint);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(crescent, glowPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(crescent, paint..style = PaintingStyle.fill);
    canvas.drawLine(
      Offset(cx, h * 0.05),
      Offset(cx, 0),
      paint..strokeWidth = w * 0.015,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WidgetSquare extends StatelessWidget {
  const WidgetSquare({
    super.key,
    this.prayerName = 'FAJR',
    this.countdown = '-02:14:30',
    this.progress = 0.75,
  });

  final String prayerName;
  final String countdown;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: _GlassContainer(
        borderRadius: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 4,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            SizedBox(
              width: 130,
              height: 130,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 4,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(kGoldColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DigitalMinaretLogo(size: 40, color: kGoldColor),
                const SizedBox(height: 8),
                Text(
                  prayerName.toUpperCase(),
                  style: GoogleFonts.cinzel(
                    color: kGoldColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: kGoldColor.withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                Text(
                  countdown,
                  style: GoogleFonts.manrope(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetTimeline extends StatelessWidget {
  const WidgetTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 160,
      child: _GlassContainer(
        borderRadius: 32,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                _TimelinePrayerItem(
                  name: 'FAJR',
                  time: '02:30',
                  isPassed: true,
                ),
                _TimelinePrayerItem(
                  name: 'SUNRISE',
                  time: '13:40',
                  isPassed: true,
                ),
                _TimelinePrayerItem(
                  name: 'DHUHR',
                  time: '16:40',
                  isActive: true,
                ),
                _TimelinePrayerItem(name: 'ASR', time: '18:20'),
                _TimelinePrayerItem(name: 'MAGHRIB', time: '18:30'),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.4,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: kGoldColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: kGoldColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelinePrayerItem extends StatelessWidget {
  const _TimelinePrayerItem({
    required this.name,
    required this.time,
    this.isActive = false,
    this.isPassed = false,
  });

  final String name;
  final String time;
  final bool isActive;
  final bool isPassed;

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive
        ? kGoldColor
        : isPassed
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: GoogleFonts.cinzel(
            color: itemColor,
            fontSize: isActive ? 18 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            shadows: isActive
                ? [
                    Shadow(
                      color: kGoldColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ]
                : const [],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.manrope(
            color: itemColor,
            fontSize: isActive ? 16 : 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class WidgetLockScreen extends StatelessWidget {
  const WidgetLockScreen({
    super.key,
    this.nextPrayer = 'ASR',
    this.timeLeft = 'IN 20M',
  });

  final String nextPrayer;
  final String timeLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kGoldColor.withValues(alpha: 0.3), width: 1),
        gradient: RadialGradient(
          colors: [kGoldColor.withValues(alpha: 0.1), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const DigitalMinaretLogo(size: 36, color: kGoldColor),
          const SizedBox(height: 4),
          Text(
            '$nextPrayer $timeLeft',
            style: GoogleFonts.manrope(
              color: kGoldColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.borderRadius = 24,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkGlassColor.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: kGoldColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
