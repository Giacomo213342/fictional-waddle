import 'package:go_router/go_router.dart';

import '../../widgets/responsive_layout.dart';

class ResponsiveShellRoute extends ShellRoute {
  ResponsiveShellRoute({
    required GoRouterWidgetBuilder builder,
    bool animateCompactSecondary = false,
    super.observers,
    required super.routes,
    super.parentNavigatorKey,
    super.navigatorKey,
    super.restorationScopeId,
  }) : super(
          builder: (context, state, child) => ResponsiveLayout(
            uri: state.uri,
            main: builder.call(context, state),
            secondary: child,
            animateCompactSecondary: animateCompactSecondary,
          ),
        );
}
