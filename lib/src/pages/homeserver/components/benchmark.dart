import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix_homeserver_recommendations/matrix_homeserver_recommendations.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../login/login.dart';

class BenchmarkWidget extends StatefulWidget {
  const BenchmarkWidget(this.result, {super.key});

  final HomeserverBenchmarkResult result;

  @override
  State<BenchmarkWidget> createState() => _BenchmarkWidgetState();
}

class _BenchmarkWidgetState extends State<BenchmarkWidget> {
  bool highlight = false;

  String get uri => LoginPage.makeRouteName(widget.result.homeserver.baseUrl);

  @override
  Widget build(BuildContext context) {
    final description = widget.result.homeserver.description;
    return MouseRegion(
      onEnter: _handlePointer,
      onHover: _handlePointer,
      onExit: _handlePointer,
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.arrowRight): _connect,
          const SingleActivator(LogicalKeyboardKey.enter): _connect,
        },
        child: Focus(
          onFocusChange: _handleFocusChange,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color:
                highlight ? Theme.of(context).focusColor : Colors.transparent,
            child: Link(
              uri: Uri.parse(uri),
              builder: (context, callback) => ListTile(
                title: Text(widget.result.homeserver.baseUrl.host),
                subtitle: description != null
                    ? Html(
                        data: description,
                        onLinkTap: _launchUrl,
                      )
                    : null,
                trailing: Focus(
                  descendantsAreFocusable: false,
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.connect,
                    icon: const Icon(Icons.rocket_launch),
                    onPressed: callback,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _connect() => context.push(uri);

  void _launchUrl(String? url, Map<String, String> attributes, element) {
    if (url != null) {
      launchUrlString(url);
    }
  }

  void _handlePointer(PointerEvent event) {
    setState(() {
      highlight = event is PointerEnterEvent || event is PointerHoverEvent;
    });
  }

  void _handleFocusChange(bool value) {
    setState(() {
      highlight = value;
    });
  }
}
