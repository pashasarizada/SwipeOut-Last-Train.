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
    return '$current/$max DAKİKA';
  }

  @override
  String trainsDelivered(int done, int total) {
    return '$done/$total TREN';
  }

  @override
  String get advance => '▶  1 DAKİKA İLERLET';

  @override
  String meterLabel(String minutes, String trains) {
    return '$minutes · $trains';
  }

  @override
  String get labelSeparator => '. ';

  @override
  String get showRulesAgain => 'Kuralları yeniden göster';

  @override
  String get hint => 'İpucu';

  @override
  String get sound => 'Ses';

  @override
  String get forecastWarning => 'Dikkat: bu dakika geçmez';

  @override
  String get cancel => 'İptal';

  @override
  String get undo => 'GERİ AL';

  @override
  String get restart => 'BAŞTAN';

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
    return '$count dakika';
  }

  @override
  String get levelLost => 'DAKİKA KALMADI';

  @override
  String get levelJammed => 'HAT KİLİTLENDİ';

  @override
  String get playAgain => 'TEKRAR OYNA';

  @override
  String get next => 'SONRAKİ';

  @override
  String get backToCity => 'ŞEHRE DÖN';

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

  @override
  String get metroPassport => 'METRO PASSPORT';

  @override
  String get stampEarned => 'Damga kazanıldı!';

  @override
  String stampedOn(String date) {
    return 'Damga: $date';
  }

  @override
  String get nightDispatcher => 'NIGHT DISPATCHER';

  @override
  String get nightDispatcherBody =>
      'Beş şehrin damgası tamam. Gece ağı artık senin.';

  @override
  String cityProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get greetingAnkara => 'Hoş geldin, başkent!';

  @override
  String get greetingBaku => 'Xoş gəlmisən!';

  @override
  String get greetingParis => 'Bienvenue !';

  @override
  String get greetingLondon => 'Welcome aboard!';

  @override
  String get greetingMoscow => 'Добро пожаловать!';

  @override
  String get board => 'BİN';

  @override
  String get openPassport => 'PASAPORTU AÇ';

  @override
  String get lineUnderConstruction => 'HAT YAPIM AŞAMASINDA';

  @override
  String get homeBoardLine => 'SON SEFER 23:59';

  @override
  String parLabel(int par) {
    return 'PAR $par';
  }

  @override
  String bestLabel(int pulses) {
    return 'EN İYİ $pulses';
  }

  @override
  String get settings => 'AYARLAR';

  @override
  String get settingsLabel => 'Ayarlar';

  @override
  String get vibration => 'Titreşim';

  @override
  String get reduceMotion => 'Hareketi azalt';

  @override
  String get language => 'Dil';

  @override
  String get languagePhone => 'TELEFON';

  @override
  String get languageTurkish => 'TÜRKÇE';

  @override
  String get languageEnglish => 'ENGLISH';
}
