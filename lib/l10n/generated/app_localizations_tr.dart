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
  String get brandLastTrain => 'LAST TRAIN';

  @override
  String get homeHeadline => 'SON SEFER BAŞLIYOR';

  @override
  String get continueGame => 'DEVAM ET';

  @override
  String get chooseCity => 'ŞEHİR SEÇ';

  @override
  String get fictionalNotice =>
      'Gerçek şehirlerden esinlenen kurgusal metro bulmacaları.';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get nightmareNetwork => 'NIGHTMARE NETWORK';

  @override
  String get cityAnkara => 'ANKARA';

  @override
  String get cityBaku => 'BAKÜ';

  @override
  String get cityParis => 'PARİS';

  @override
  String get cityLondon => 'LONDRA';

  @override
  String get cityMoscow => 'MOSKOVA';

  @override
  String pulseCounter(int current, int max) {
    return '$current/$max PULSE';
  }

  @override
  String trainsDelivered(int done, int total) {
    return '🚆 $done/$total';
  }

  @override
  String controlsLeft(int left) {
    return 'Kontrol: $left/1';
  }

  @override
  String get advance => '▶  1 DAKİKA İLERLET';

  @override
  String get cancel => 'İptal';

  @override
  String get undo => 'Geri Al';

  @override
  String get restart => 'Baştan';

  @override
  String pendingSwitch(String node) {
    return 'Makas $node';
  }

  @override
  String pendingSignal(String node) {
    return 'Sinyal $node';
  }

  @override
  String get levelComplete => 'HAT TEMİZ';

  @override
  String pulsesUsed(int count) {
    return '$count pulse';
  }

  @override
  String get levelLost => 'Dakika kalmadı';

  @override
  String get levelJammed => 'Hat kilitlendi';

  @override
  String get playAgain => 'Tekrar Oyna';

  @override
  String get next => 'Sonraki';

  @override
  String get backToCity => 'Şehre Dön';

  @override
  String get failCollision => 'İki tren aynı durakta karşılaştı.';

  @override
  String get failHeadOn => 'Kafa kafaya! İki tren aynı rayda.';

  @override
  String get failBlocked => 'Bir tren bekleyen trene çarptı.';

  @override
  String get failWrongGoal => 'Yanlış hat: o durak başka trenin.';

  @override
  String get failOutOfPulses => 'Dakika kalmadı.';
}
