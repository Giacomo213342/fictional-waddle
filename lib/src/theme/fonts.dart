enum PolyculeFonts {
  /// Sono - monospace font
  sono('Sono'),

  /// Arial - Windows sans-serif font
  arial('Arial'),

  /// Noto Color Emoji - emoji fallback font
  notoColorEmoji('Noto Color Emoji'),

  /// Noto Sana - noto fallbacl font
  notoSans('Noto Color Emoji'),

  /// GL Suetterlin - German hand writing
  glSuetterlin('GL Suetterlin'),

  /// OpenDyslexic - dyslexia friendly accessibility font
  openDyslexic('OpenDyslexic'),

  /// Inclusive Sans - sans-serif font with accessible typeface
  inclusiveSans('Inclusive Sans');

  const PolyculeFonts(this.name);

  final String name;

  @override
  String toString() => name;
}
