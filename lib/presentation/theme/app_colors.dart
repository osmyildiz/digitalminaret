import 'package:flutter/material.dart';

class AppColors {
  static const Color nightBlue = Color(0xFF153553);
  static const Color mistBlue = Color(0xFF4A708D);
  static const Color sand = Color(0xFFA2A07D);
  static const Color mint = Color(0xFF4EDAA1);
  static const Color amber = Color(0xFFFFC66D);
  static const Color frost = Color(0x26FFFFFF);
  static const Color white = Color(0xFFF7FAFD);
  static const Color textPrimary = Color(0xFFF2F6FA);
  static const Color textSecondary = Color(0xB8DDE7EF);

  static const Color passed = Color(0x80DDE7EF);
  static const Color upcoming = Color(0xFF9DD5FF);
  static const Color current = Color(0xFF4EDAA1);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [nightBlue, mistBlue, sand],
  );
}
