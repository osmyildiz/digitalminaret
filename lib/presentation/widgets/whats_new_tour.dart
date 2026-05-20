import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Multi-step "what's new" walkthrough shown to returning users after an
/// update. Each step pairs a real product screenshot with a highlight
/// rectangle drawn over the relevant UI element, so the user sees both
/// the feature and where to find it. The final step's primary action
/// dismisses the modal; the caller is responsible for persisting that
/// the announcement has been seen.
class WhatsNewTour extends StatefulWidget {
  const WhatsNewTour({super.key});

  @override
  State<WhatsNewTour> createState() => _WhatsNewTourState();
}

class _WhatsNewTourState extends State<WhatsNewTour> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = <_TourStep>[
      _TourStep(
        title: l10n.whatsNewLockStepTitle,
        body: l10n.whatsNewLockStepBody,
        asset: 'assets/whats_new/lock_screen.png',
        assetAspectRatio: 1206 / 1000,
        // Image is cropped to the Live Activity card (1206x1000). The
        // highlight covers the whole live timeline area down through
        // the big H:MM:SS countdown.
        highlight: const Rect.fromLTRB(0.05, 0.38, 0.95, 0.92),
      ),
      _TourStep(
        title: l10n.whatsNewSettingsStepTitle,
        body: l10n.whatsNewSettingsStepBody,
        asset: 'assets/whats_new/settings.png',
        assetAspectRatio: 1206 / 1050,
        // Image is cropped to the ADHAN AUDIO section (1206x1050). The
        // "Lock screen prayer timeline" row sits roughly at 62–84%
        // vertically.
        highlight: const Rect.fromLTRB(0.04, 0.62, 0.96, 0.84),
      ),
    ];

    final isLast = _index == steps.length - 1;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      backgroundColor: const Color(0xFF0A0F1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    l10n.whatsNewTitle,
                    style: const TextStyle(
                      color: Color(0xFFFFD98F),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _TourPage(step: steps[i]),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: active ? 20 : 6,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFFD98F)
                        : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD98F),
                    foregroundColor: const Color(0xFF030612),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    if (isLast) {
                      Navigator.of(context).pop();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Text(isLast ? l10n.whatsNewGotIt : l10n.whatsNewNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourStep {
  const _TourStep({
    required this.title,
    required this.body,
    required this.asset,
    required this.assetAspectRatio,
    required this.highlight,
  });

  final String title;
  final String body;
  final String asset;
  // Native aspect ratio of the asset (width / height). Used to wrap
  // Image + highlight painter in an AspectRatio so they map 1:1 without
  // BoxFit.cover cropping.
  final double assetAspectRatio;
  // Relative rectangle inside the asset image (0..1).
  final Rect highlight;
}

class _TourPage extends StatelessWidget {
  const _TourPage({required this.step});

  final _TourStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: step.assetAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // BoxFit.fill stretches the image to exactly match
                      // the AspectRatio box (which has the asset's
                      // native ratio), so no crop, no letterbox, and
                      // the painter's fractional coords map directly to
                      // image pixels.
                      Image.asset(step.asset, fit: BoxFit.fill),
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _HighlightDimPainter(step.highlight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            step.body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Draws a translucent dim everywhere except inside the highlight rect,
/// plus a soft glowing border around the highlight rect itself. The
/// highlight rect is in 0..1 fraction coordinates of the paint area.
class _HighlightDimPainter extends CustomPainter {
  _HighlightDimPainter(this.highlightFrac);

  final Rect highlightFrac;

  @override
  void paint(Canvas canvas, Size size) {
    final highlight = Rect.fromLTRB(
      highlightFrac.left * size.width,
      highlightFrac.top * size.height,
      highlightFrac.right * size.width,
      highlightFrac.bottom * size.height,
    );
    final dim = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final fullPath = Path()..addRect(Offset.zero & size);
    final cutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(highlight, const Radius.circular(14)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, cutPath),
      dim,
    );

    // Glowing border for the highlight.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFFFFD98F)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlight, const Radius.circular(14)),
      glow,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFD98F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(highlight, const Radius.circular(14)),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _HighlightDimPainter old) =>
      old.highlightFrac != highlightFrac;
}
