import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1526739547870247/7357090852';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2435281174';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
