import '../../data/services/audio_service.dart';

class PlayAdhanUseCase {
  const PlayAdhanUseCase(this._audioService);

  final AudioService _audioService;

  Future<void> call({bool isShort = true}) {
    return _audioService.playAdhan(isShort: isShort);
  }
}
