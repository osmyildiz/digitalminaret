import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/constants/adhan_packs.dart';
import '../../core/constants/audio_assets.dart';
import '../../core/enums/prayer_type.dart';
import 'adhan_pack_download_service.dart';

class AudioService {
  AudioService._internal({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _playerStateSub = _player.playerStateStream.listen((state) {
      final active =
          state.playing && state.processingState != ProcessingState.completed;
      isPlaying.value = active;
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
      }
    });
  }

  static final AudioService _instance = AudioService._internal();

  factory AudioService({AudioPlayer? player}) => _instance;

  final AudioPlayer _player;
  final AdhanPackDownloadService _packDownloadService =
      AdhanPackDownloadService();
  late final StreamSubscription<PlayerState> _playerStateSub;
  static bool _sessionReady = false;
  static final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

  Future<void> _ensureAudioSession() async {
    if (_sessionReady) {
      return;
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    _sessionReady = true;
  }

  Future<void> playAdhan({bool isShort = true}) async {
    await _ensureAudioSession();
    final asset = isShort ? AudioAssets.adhanShort30s : AudioAssets.adhanFull;
    await _player.setVolume(isMuted.value ? 0.0 : 1.0);
    await _player.setAsset(asset);
    await _player.play();
  }

  Future<void> playFullAdhanForPrayer({
    required PrayerType prayerType,
    required String selectedPackId,
    bool playPostAdhanDua = true,
  }) async {
    await _ensureAudioSession();
    await _player.setVolume(isMuted.value ? 0.0 : 1.0);

    final duaSource = playPostAdhanDua
        ? AudioSource.asset(AudioAssets.postAdhanDua)
        : null;

    if (selectedPackId != AdhanPacks.defaultPackId) {
      final localPath = await _packDownloadService.localPathFor(
        packId: selectedPackId,
        prayerType: prayerType,
      );
      if (localPath != null && await File(localPath).exists()) {
        try {
          if (duaSource == null) {
            await _player.setFilePath(localPath);
          } else {
            await _player.setAudioSource(
              ConcatenatingAudioSource(
                children: <AudioSource>[AudioSource.file(localPath), duaSource],
              ),
            );
          }
          await _player.play();
          return;
        } catch (_) {
          // Fallback to bundled Turkish assets if downloaded file is invalid.
        }
      }
    }

    if (duaSource == null) {
      await _player.setAsset(_turkiyeAssetByPrayer(prayerType));
    } else {
      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: <AudioSource>[
            AudioSource.asset(_turkiyeAssetByPrayer(prayerType)),
            duaSource,
          ],
        ),
      );
    }
    await _player.play();
  }

  Future<void> playBundledAdhanForPrayer(PrayerType prayerType) async {
    await _ensureAudioSession();
    await _player.setVolume(isMuted.value ? 0.0 : 1.0);
    await _player.setAsset(_turkiyeAssetByPrayer(prayerType));
    await _player.play();
  }

  Future<void> toggleMute() async {
    final next = !isMuted.value;
    isMuted.value = next;
    await _player.setVolume(next ? 0.0 : 1.0);
  }

  String _turkiyeAssetByPrayer(PrayerType prayerType) {
    switch (prayerType) {
      case PrayerType.fajr:
      case PrayerType.sunrise:
        return AudioAssets.turkiyeFajr;
      case PrayerType.dhuhr:
        return AudioAssets.turkiyeDhuhr;
      case PrayerType.asr:
        return AudioAssets.turkiyeAsr;
      case PrayerType.maghrib:
        return AudioAssets.turkiyeMaghrib;
      case PrayerType.isha:
        return AudioAssets.turkiyeIsha;
    }
  }

  Future<void> stop() {
    return _player.stop();
  }

  Future<void> pause() {
    return _player.pause();
  }

  Future<void> dispose() {
    _playerStateSub.cancel();
    return _player.dispose();
  }
}
