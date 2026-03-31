import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

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
    if (!_isSupportedMobilePlatform()) {
      return GestureDetector(
        onTap: _openQiblaScreen,
        child: _badge(const Icon(Icons.explore_off, color: Colors.grey)),
      );
    }

    if (!_sensorSupported || !_serviceEnabled || !_permissionGranted) {
      return GestureDetector(
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
      );
    }

    return StreamBuilder<QiblahDirection>(
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
          child:
              _badge(const Icon(Icons.error_outline, color: Colors.redAccent)),
        );
      },
    );
  }

  Widget _badge(Widget child) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.30),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Center(child: child),
    );
  }
}
