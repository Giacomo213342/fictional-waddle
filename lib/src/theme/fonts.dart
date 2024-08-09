enum PolyculeFonts {
  /// Sono - monospace font
  sono('Sono'),

  /// Arial - Windows sans-serif font
  arial('Arial'),

  /// Noto Color Emoji - emoji fallback font
  notoColorEmoji('Noto Color Emoji'),

  /// Noto Sans - noto fallback font
  notoSans('Noto Sans'),

  /// Noto Sans Mono - noto monospace font
  notoSansMono('Noto Sans Mono'),

  /// GL Suetterlin - German hand writing
  glSuetterlin('GL Suetterlin'),

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
