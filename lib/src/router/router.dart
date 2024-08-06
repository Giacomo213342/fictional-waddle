import 'package:flutter/foundation.dart';

import 'package:go_router/go_router.dart';

import '../pages/account_selector/account_selector.dart';
import '../pages/application_settings/application_settings.dart';
import '../pages/application_settings/pages/appearance.dart';
import '../pages/fatal_error/fatal_error_page.dart';
import '../pages/homeserver/homeserver.dart';
import '../pages/login/login.dart';
import '../pages/public_room/public_room.dart';
import '../pages/room/room.dart';
import '../pages/room_list/room_list.dart';
import '../pages/splash_screen/splash_screen.dart';
import '../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../widgets/placeholder.dart';
import 'extensions/go_router_path_extension.dart';
import 'extensions/homeserver_uri_route.dart';
import 'extensions/matrix_deeplink_route.dart';
import 'extensions/matrix_injected_route.dart';
import 'extensions/must_be_logged_out_route.dart';
import 'extensions/polycule_deeplink_route.dart';
import 'extensions/requires_login_route.dart';
import 'extensions/responsive_shell_route.dart';
import 'extensions/room_available_route.dart';

class PolyculeRouter extends GoRouter {
  PolyculeRouter()
      : super.routingConfig(
          debugLogDiagnostics: kDebugMode,
          routingConfig: _ConstantRoutingConfig(
            RoutingConfig(
              routes: [
                GoRoute(
                  path: FatalErrorPage.routeName,
                  builder: (context, state) =>
                      FatalErrorPage(error: state.extra),
                ),
                PolyculeDeeplinkRoute(),
                MatrixInjectedRoute(
                  routes: [
                    // in order to handle `/`
                    GoRoute(
                      path: SplashPage.routeName,
                      builder: (context, state) => const SplashPage(),
                    ),
                    // in order to initialize particular client
                    GoRoute(
                      path: SplashPage.routeName.asMultiClientRoute(),
                      builder: (context, state) => SplashPage(
                        key: ValueKey(state.uri.toString()),
                      ),
                    ),
                    GoRoute(
                      path: AccountSelectorPage.routeName,
                      builder: (context, state) => AccountSelectorPage(
                        redirect: Uri.decodeComponent(
                          state.uri.queryParameters['redirect']!,
                        ),
                      ),
                    ),
                    ResponsiveShellRoute(
                      builder: (context, state) =>
                          const ApplicationSettingsPage(),
                      routes: [
                        GoRoute(
                          path: ApplicationSettingsPage.routeName,
                          builder: (context, state) =>
                              const PolyculePlaceholder(),
                          routes: [
                            GoRoute(
                              path: AppearanceSettingsPage.routeName,
                              builder: (context, state) =>
                                  const AppearanceSettingsPage(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    MustBeLoggedOutRoute(
                      path: HomeserverPage.routeName.asMultiClientRoute(),
                      builder: (context, state) => const HomeserverPage(),
                    ),
                    HomeserverUriRoute(
                      path: LoginPage.routeName.asMultiClientRoute(),
                      builder: (context, state, uri) =>
                          LoginPage(homeserver: uri),
                    ),
                    RequiresLoginRoute(
                      path: SsssBootstrapPage.routeName.asMultiClientRoute(),
                      builder: (context, state) => const SsssBootstrapPage(),
                    ),
                    ResponsiveShellRoute(
                      builder: (context, state) => RoomListPage(
                        key: ValueKey(state.pathParameters['client']),
                      ),
                      routes: [
                        RequiresLoginRoute(
                          path: RoomListPage.routeName.asMultiClientRoute(),
                          builder: (context, state) =>
                              const PolyculePlaceholder(),
                          routes: [
                            RoomAvailableRoute(
                              path: RoomPage.pathParameter.asGoRouterPath(),
                              builder: (context, state, room) => RoomPage(
                                room: room,
                              ),
                              roomUnavailableBuilder: (
                                context,
                                state,
                                filter,
                                via,
                                action,
                              ) =>
                                  PublicRoomPage(
                                filter: filter,
                                via: via,
                                action: action,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                MatrixDeeplinkRoute(),
              ],
            ),
          ),
        );
}

/// A routing config that is never going to change.
class _ConstantRoutingConfig extends ValueListenable<RoutingConfig> {
  const _ConstantRoutingConfig(this.value);

  @override
  void addListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  void removeListener(VoidCallback listener) {
    // Intentionally empty because listener will never be called.
  }

  @override
  final RoutingConfig value;
}
