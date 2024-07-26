import 'package:flutter_html/flutter_html.dart';

extension ParentFontSizeExtension on ExtensionContext {
  FontSize? tryGetParentFontSize() {
    var currentElement = element;
    while (currentElement?.parent != null) {
      currentElement = currentElement?.parent;
      final size = parser.style[(currentElement!.localName!)]?.fontSize;
      if (size != null) {
        return size;
      }
    }
    return null;
  }
}
