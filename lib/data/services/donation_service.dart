import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/constants/app_constants.dart';

class DonationPackage {
  const DonationPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
    this.storePackage,
    this.storeProduct,
  });

  final String id;
  final String title;
  final String description;
  final String priceLabel;
  final Package? storePackage;
  final StoreProduct? storeProduct;
}

class DonationService {
  DonationService._internal();
  static final DonationService _instance = DonationService._internal();
  factory DonationService() => _instance;

  bool _initialized = false;

  Future<String> collectDebugReport() async {
    final buffer = StringBuffer();
    buffer.writeln('platform: ${kIsWeb ? "web" : Platform.operatingSystem}');
    buffer.writeln('iosKeyEmpty: ${AppConstants.revenueCatAppleApiKey.isEmpty}');
    buffer.writeln(
      'androidKeyEmpty: ${AppConstants.revenueCatGoogleApiKey.isEmpty}',
    );

    final ok = await initialize();
    buffer.writeln('initialize: $ok');
    if (!ok) {
      return buffer.toString();
    }

    try {
      final appUserId = await Purchases.appUserID;
      buffer.writeln('appUserID: $appUserId');
    } catch (error) {
      buffer.writeln('appUserID error: $error');
    }

    try {
      final offerings = await Purchases.getOfferings();
      buffer.writeln('offering.current: ${offerings.current?.identifier}');
      buffer.writeln('offering.all: ${offerings.all.keys.join(", ")}');
      for (final entry in offerings.all.entries) {
        final ids = entry.value.availablePackages
            .map((p) => p.storeProduct.identifier)
            .join(', ');
        buffer.writeln('offering[${entry.key}] products: $ids');
      }
    } catch (error) {
      buffer.writeln('offerings error: $error');
    }

    try {
      final products = await Purchases.getProducts(const [
        AppConstants.tipSmallProductId,
        AppConstants.tipMediumProductId,
        AppConstants.tipLargeProductId,
      ]);
      buffer.writeln(
        'direct products: ${products.map((p) => p.identifier).join(", ")}',
      );
    } catch (error) {
      buffer.writeln('direct products error: $error');
    }

    return buffer.toString();
  }

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }
    if (kIsWeb) {
      return false;
    }

    final apiKey = _platformApiKey();
    if (apiKey.isEmpty) {
      return false;
    }

    try {
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      _initialized = true;
      return true;
    } catch (error) {
      // If already configured elsewhere (e.g. app bootstrap), continue.
      final message = error.toString().toLowerCase();
      if (message.contains('already') && message.contains('configure')) {
        _initialized = true;
        return true;
      }
      debugPrint('[Donate] initialize failed: $error');
      return false;
    }
  }

  Future<List<DonationPackage>> loadTipPackages() async {
    final ok = await initialize();
    if (!ok) {
      return const [];
    }

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } catch (error) {
      debugPrint('[Donate] getOfferings failed: $error');
      return _loadDirectProductsFallback();
    }

    final current = offerings.current;
    final candidates = <Package>[
      ...(current?.availablePackages ?? const <Package>[]),
      for (final offering in offerings.all.values) ...offering.availablePackages,
    ];
    if (candidates.isEmpty) {
      debugPrint('[Donate] offerings empty current=${current?.identifier} all=${offerings.all.keys}');
      return _loadDirectProductsFallback();
    }

    final idOrder = <String>[
      AppConstants.tipSmallProductId,
      AppConstants.tipMediumProductId,
      AppConstants.tipLargeProductId,
    ];

    final packageById = <String, Package>{
      for (final package in candidates)
        package.storeProduct.identifier: package,
    };

    final result = <DonationPackage>[];
    for (final id in idOrder) {
      final pkg = packageById[id];
      if (pkg == null) {
        continue;
      }
      result.add(
        DonationPackage(
          id: id,
          title: _titleById(id),
          description: _descriptionById(id),
          priceLabel: pkg.storeProduct.priceString,
          storePackage: pkg,
        ),
      );
    }
    debugPrint(
      '[Donate] matched products: ${result.map((e) => e.id).join(", ")} '
      'from candidates=${candidates.map((e) => e.storeProduct.identifier).join(", ")}',
    );
    if (result.isEmpty) {
      return _loadDirectProductsFallback();
    }
    return result;
  }

  Future<bool> purchase(DonationPackage package) async {
    final ok = await initialize();
    if (!ok) {
      return false;
    }
    try {
      if (package.storePackage != null) {
        await Purchases.purchasePackage(package.storePackage!);
      } else if (package.storeProduct != null) {
        await Purchases.purchaseStoreProduct(package.storeProduct!);
      } else {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<DonationPackage>> _loadDirectProductsFallback() async {
    final ids = <String>[
      AppConstants.tipSmallProductId,
      AppConstants.tipMediumProductId,
      AppConstants.tipLargeProductId,
    ];

    try {
      final products = await Purchases.getProducts(ids);
      if (products.isEmpty) {
        debugPrint('[Donate] direct products empty');
        return const [];
      }

      final byId = <String, StoreProduct>{
        for (final product in products) product.identifier: product,
      };
      final result = <DonationPackage>[];
      for (final id in ids) {
        final product = byId[id];
        if (product == null) {
          continue;
        }
        result.add(
          DonationPackage(
            id: id,
            title: _titleById(id),
            description: _descriptionById(id),
            priceLabel: product.priceString,
            storeProduct: product,
          ),
        );
      }
      debugPrint(
        '[Donate] direct products matched: ${result.map((e) => e.id).join(", ")}',
      );
      return result;
    } catch (error) {
      debugPrint('[Donate] direct products failed: $error');
      return const [];
    }
  }

  String _platformApiKey() {
    if (kIsWeb) {
      return '';
    }
    if (Platform.isIOS) {
      return AppConstants.revenueCatAppleApiKey;
    }
    if (Platform.isAndroid) {
      return AppConstants.revenueCatGoogleApiKey;
    }
    return '';
  }

  String _titleById(String id) {
    switch (id) {
      case AppConstants.tipSmallProductId:
        return 'Small Tip';
      case AppConstants.tipMediumProductId:
        return 'Medium Tip';
      case AppConstants.tipLargeProductId:
        return 'Large Tip';
      default:
        return 'Support';
    }
  }

  String _descriptionById(String id) {
    switch (id) {
      case AppConstants.tipSmallProductId:
        return 'One-time support level: \$0.99';
      case AppConstants.tipMediumProductId:
        return 'One-time support level: \$4.99';
      case AppConstants.tipLargeProductId:
        return 'One-time support level: \$99.99';
      default:
        return 'Support the project.';
    }
  }
}
