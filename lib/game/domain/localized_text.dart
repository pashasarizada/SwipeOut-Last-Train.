/// Text authored in level data for both shipped languages.
final class LocalizedText {
  const LocalizedText({required this.tr, required this.en});

  final String tr;
  final String en;

  /// Turkish for `tr`, English for everything else.
  String of(String languageCode) => languageCode == 'tr' ? tr : en;
}
