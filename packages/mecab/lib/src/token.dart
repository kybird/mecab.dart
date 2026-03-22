/// A morphological token from MeCab analysis.
///
/// Features follow the IpaDic format:
/// pos, pos1, pos2, pos3, conjugation_type, conjugation_form, base, reading, pronunciation
class MecabToken {
  /// Surface form (how it appears in text).
  final String surface;

  /// Raw feature string from MeCab.
  final String feature;

  /// Part-of-speech fields parsed from [feature].
  final List<String> features;

  MecabToken(this.surface, this.feature)
      : features = feature.split(',');

  /// Primary part of speech (e.g. 名詞, 動詞, 助詞).
  String get pos => features.isNotEmpty ? features[0] : '';

  /// POS subcategory 1.
  String get pos1 => features.length > 1 ? features[1] : '';

  /// Base/dictionary form.
  String get base => features.length > 6 ? features[6] : surface;

  /// Reading in katakana.
  String get reading => features.length > 7 ? features[7] : '';

  /// Pronunciation in katakana.
  String get pronunciation => features.length > 8 ? features[8] : reading;

  @override
  String toString() => '$surface\t$feature';
}
