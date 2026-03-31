import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/prayer_names.dart';
import '../../core/enums/prayer_type.dart';
import '../theme/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    required this.targetTime,
    required this.prayerType,
    super.key,
  });

  final DateTime targetTime;
  final PrayerType prayerType;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.targetTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _remaining = widget.targetTime.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safe = _remaining.isNegative ? Duration.zero : _remaining;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);

    return Card(
      color: AppColors.frost,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Prayer: ${PrayerNames.en[widget.prayerType] ?? widget.prayerType.name}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 38,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
