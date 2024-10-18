enum PolyculeFonts {
  /// Overpass Mono - monospace font
  overpassMono('Overpass Mono'),

  /// Arial - Windows sans-serif font
  arial('Arial'),

  /// Noto Color Emoji - emoji fallback font
  notoColorEmoji('Noto Color Emoji'),

  /// Noto Sans - noto fallback font
  notoSans('Noto Sans'),

  /// Noto Sans Mono - noto monospace font
  notoSansMono('Noto Sans Mono'),

  /// Marck Script - serif hand writing
  marckScript('Marck Script'),

  /// OpenDyslexic - dyslexia friendly accessibility font
  openDyslexic('OpenDyslexic'),

  /// Inclusive Sans - sans-serif font with accessible typeface
  inclusiveSans('Inclusive Sans'),

  /// Vollkorn - serif font
  vollkorn('Vollkorn'),

  /// Roboto - Flutter fallback font
  roboto('Roboto');

  const PolyculeFonts(this.name);

  final String name;

  @override
  String toString() => name;
}
