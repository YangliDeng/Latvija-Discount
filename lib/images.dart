import 'package:flutter/foundation.dart';

class SuperMarket {
  final String id;
  final String url;

  const SuperMarket({
    required this.id,
    required this.url,
});

}

class Images {
  static final marketIcons = <SuperMarket> [
    SuperMarket(
      id: 'rimi',
      url: 'assets/symbols/rimiSymbol.png'
    ),
    SuperMarket(
        id: 'maxima',
        url: 'assets/symbols/maximaSymbol.png'
    ),
    SuperMarket(
        id: 'lidl',
        url: 'assets/symbols/lidlSymbol.png'
    ),
  ];
}