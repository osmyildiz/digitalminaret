import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/locale_string.dart';
import '../../l10n/app_localizations.dart';
import '../screens/qibla_screen.dart';

class MiniQiblaCompass extends StatefulWidget {
  const MiniQiblaCompass({super.key});

  @override
  State<MiniQiblaCompass> createState() => _MiniQiblaCompassState();
}

class _MiniQiblaCompassState extends State<MiniQiblaCompass> {
  bool _permissionGranted = false;
  bool _serviceEnabled = false;
  bool _sensorSupported = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (!_isSupportedMobilePlatform()) {
      return;
    }

    try {
      final sensorSupport = await FlutterQiblah.androidDeviceSensorSupport();
      final locationStatus = await FlutterQiblah.checkLocationStatus();
      var permission = locationStatus.status;

      if (permission == LocationPermission.denied) {
        permission = await FlutterQiblah.requestPermissions();
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _sensorSupported = sensorSupport ?? true;
        _serviceEnabled = locationStatus.enabled;
        _permissionGranted =
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      });
    } on MissingPluginException {
      if (!mounted) {
        return;
      }
      setState(() {
        _permissionGranted = false;
        _serviceEnabled = false;
        _sensorSupported = false;
      });
    } on PlatformException {
      if (!mounted) {
        return;
      }
      setState(() {
        _permissionGranted = false;
        _serviceEnabled = false;
        _sensorSupported = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _permissionGranted = false;
        _serviceEnabled = false;
        _sensorSupported = false;
      });
    }
  }

  bool _isSupportedMobilePlatform() {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  void _openQiblaScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const QiblaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context)!.qibla;

    if (!_isSupportedMobilePlatform()) {
      return _withLabel(
        context,
        label,
        GestureDetector(
          onTap: _openQiblaScreen,
          child: _badge(const Icon(Icons.explore_off, color: Colors.grey)),
        ),
      );
    }

    if (!_sensorSupported || !_serviceEnabled || !_permissionGranted) {
      return _withLabel(
        context,
        label,
        GestureDetector(
          onTap: () async {
            await _checkStatus();
            if (!_permissionGranted) {
              await Geolocator.openAppSettings();
            } else if (!_serviceEnabled) {
              await Geolocator.openLocationSettings();
            }
          },
          onDoubleTap: _openQiblaScreen,
          child: _badge(const Icon(Icons.explore_off, color: Colors.grey)),
        ),
      );
    }

    return _withLabel(
      context,
      label,
      StreamBuilder<QiblahDirection>(
        stream: FlutterQiblah.qiblahStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GestureDetector(
              onTap: _openQiblaScreen,
              child: _badge(const Icon(Icons.explore, color: Colors.white54)),
            );
          }

          if (snapshot.hasData) {
            final qiblaDirection = snapshot.data!;
            final angle = qiblaDirection.qiblah * (math.pi / 180) * -1;
            return GestureDetector(
              onTap: _openQiblaScreen,
              child: Transform.rotate(
                angle: angle,
                child: _badge(
                  const Icon(
                      Icons.navigation, color: Colors.greenAccent, size: 24),
                ),
              ),
            );
          }

          return GestureDetector(
            onTap: _openQiblaScreen,
            child: _badge(
              const Icon(Icons.error_outline, color: Colors.redAccent),
            ),
          );
        },
      ),
    );
  }

  /// Wraps the compass badge with a "QIBLA" caption so first-time users
  /// can tell what the icon is and that it's tappable. The label rotates
  /// with the Transform parent in the streaming branch — to avoid that
  /// we pass the *outer* GestureDetector child (not the inner badge) so
  /// the label stays upright.
  Widget _withLabel(BuildContext context, String label, Widget child) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 2),
        Text(
          label.toLocaleUpperCase(context),
          style: GoogleFonts.cinzel(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }

  Widget _badge(Widget child) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.32),
        border: Border.all(
          color: const Color(0xFFFFE6A8).withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Center(child: child),
    );
  }
}
