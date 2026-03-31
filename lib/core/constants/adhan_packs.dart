class AdhanPack {
  const AdhanPack({
    required this.id,
    required this.name,
    required this.flag,
    required this.baseUrl,
  });

  final String id;
  final String name;
  final String flag;
  final String baseUrl;
}

class AdhanPacks {
  static const String defaultPackId = 'tr_istanbul';
  static const String _repoBase =
      'https://raw.githubusercontent.com/osmyildiz/digitalminaret-adhan-packs/main';

  static const List<AdhanPack> all = [
    AdhanPack(
      id: 'tr_istanbul',
      name: 'Türkiye (Istanbul Style)',
      flag: 'TR',
      baseUrl: '$_repoBase/tr_istanbul/',
    ),
    AdhanPack(
      id: 'sa_makkah',
      name: 'Makkah (Kaaba Imams)',
      flag: 'SA',
      baseUrl: '$_repoBase/sa_makkah/',
    ),
    AdhanPack(
      id: 'eg_cairo',
      name: 'Egypt (Cairo)',
      flag: 'EG',
      baseUrl: '$_repoBase/eg_cairo/',
    ),
    AdhanPack(
      id: 'pk_lahore',
      name: 'Pakistan (Lahore)',
      flag: 'PK',
      baseUrl: '$_repoBase/pk_lahore/',
    ),
  ];

  static AdhanPack byId(String id) {
    return all.firstWhere((pack) => pack.id == id, orElse: () => all.first);
  }
}
