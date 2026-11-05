// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'SwipeOut: Last Train';

  @override
  String get play => 'Oyna';

  @override
  String get cityIstanbul => 'İSTANBUL';

  @override
  String levelLabel(String number) {
    return 'BÖLÜM $number';
  }

  @override
  String moves(int count) {
    return 'Hamle: $count';
  }

  @override
  String get undo => 'Geri Al';

  @override
  String get restart => 'Baştan';

  @override
  String get hint => 'İpucu';

  @override
  String get levelComplete => 'Hat temiz!';

  @override
  String get next => 'Sonraki';

  @override
  String get replay => 'Tekrar';

  @override
  String get tutorialSelectSwipe =>
      'Trene dokun, sonra kaydırarak bir kare ilerlet.';

  @override
  String get tutorialSwitch =>
      'Yönü değiştirmek için makasa dokun. Her dokunuş bir hamle.';

  @override
  String get tutorialOrder =>
      'Trenler birbirinin içinden geçemez. Önce kim gidecek, seç.';

  @override
  String get blockedWrongStation => 'Bu tren için yanlış istasyon.';

  @override
  String get blockedOccupied => 'Yolda başka bir tren var.';

  @override
  String get blockedNoTrack => 'O yönde ray yok.';

  @override
  String get blockedSwitchOccupied => 'Makasın üstünde tren var.';

  @override
  String get selectTrainFirst => 'Önce bir trene dokun.';

  @override
  String get hintUnavailable => 'Şu an ipucu yok.';
}
