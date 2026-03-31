import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/constants/adhan_packs.dart';
import '../../core/enums/prayer_type.dart';

abstract class AdhanPackDownloadGateway {
  Future<bool> isPackDownloaded(String packId);

  Future<void> downloadPack(AdhanPack pack);

  Future<String?> localPathFor({
    required String packId,
    required PrayerType prayerType,
  });
}

class AdhanPackDownloadService implements AdhanPackDownloadGateway {
  AdhanPackDownloadService._internal();

  static final AdhanPackDownloadService _instance =
      AdhanPackDownloadService._internal();

  factory AdhanPackDownloadService() => _instance;

  static const List<String> _requiredFiles = <String>[
    'fajr.m4a',
    'dhuhr.m4a',
    'asr.m4a',
    'maghrib.m4a',
    'isha.m4a',
  ];

  Future<Directory> _packDirectory(String packId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/adhan_packs/$packId');
  }

  @override
  Future<bool> isPackDownloaded(String packId) async {
    final dir = await _packDirectory(packId);
    for (final file in _requiredFiles) {
      final f = File('${dir.path}/$file');
      if (!await f.exists()) {
        return false;
      }
      final len = await f.length();
      if (len <= 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> downloadPack(AdhanPack pack) async {
    final dir = await _packDirectory(pack.id);
    await dir.create(recursive: true);

    final client = HttpClient();
    try {
      for (final fileName in _requiredFiles) {
        final request = await client.getUrl(
          Uri.parse('${pack.baseUrl}$fileName'),
        );
        final response = await request.close();
        if (response.statusCode != 200) {
          throw HttpException(
            'Failed to download $fileName (${response.statusCode})',
          );
        }

        final bytes = await response.fold<List<int>>(
          <int>[],
          (prev, chunk) => prev..addAll(chunk),
        );
        final target = File('${dir.path}/$fileName');
        await target.writeAsBytes(bytes, flush: true);
      }
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<String?> localPathFor({
    required String packId,
    required PrayerType prayerType,
  }) async {
    final dir = await _packDirectory(packId);
    final file = File('${dir.path}/${_fileNameByPrayer(prayerType)}');
    if (!await file.exists()) {
      return null;
    }
    return file.path;
  }

  String _fileNameByPrayer(PrayerType prayerType) {
    switch (prayerType) {
      case PrayerType.fajr:
      case PrayerType.sunrise:
        return 'fajr.m4a';
      case PrayerType.dhuhr:
        return 'dhuhr.m4a';
      case PrayerType.asr:
        return 'asr.m4a';
      case PrayerType.maghrib:
        return 'maghrib.m4a';
      case PrayerType.isha:
        return 'isha.m4a';
    }
  }
}
