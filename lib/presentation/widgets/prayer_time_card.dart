import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/prayer_names.dart';
import '../../core/enums/prayer_type.dart';
import '../theme/app_colors.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    required this.type,
    required this.time,
    required this.isPassed,
    required this.isCurrent,
    super.key,
  });

  final PrayerType type;
  final DateTime time;
  final bool isPassed;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final statusColor = isCurrent
        ? AppColors.current
        : (isPassed ? AppColors.passed : AppColors.upcoming);

    return Card(
      color: AppColors.frost,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              isPassed
                  ? Icons.check
                  : (isCurrent ? Icons.arrow_right : Icons.schedule),
              color: statusColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                PrayerNames.en[type] ?? type.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              DateFormat.jm().format(time),
              style: TextStyle(
                color: statusColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
