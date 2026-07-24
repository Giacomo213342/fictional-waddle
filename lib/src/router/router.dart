import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../pages/account_selector/account_selector.dart';
import '../pages/account_settings/account_settings.dart';
import '../pages/account_settings/account_settings_back_navigation.dart';
import '../pages/account_settings/pages/emoji_settings/emoji_settings.dart';
import '../pages/account_settings/pages/notification_settings/notification_settings.dart';
import '../pages/account_settings/pages/session_settings/session_settings.dart';
import '../pages/application_settings/application_settings.dart';
import '../pages/application_settings/pages/appearance.dart';
import '../pages/application_settings/pages/error_reporting.dart';
import '../pages/application_settings/pages/logs.dart';
import '../pages/application_settings/pages/network.dart';
import '../pages/application_settings/pages/push.dart';
import '../pages/application_splash_screen/application_splash_screen.dart';
import '../pages/fatal_error/fatal_error_page.dart';
import '../pages/homeserver/homeserver.dart';
import '../pages/login/login.dart';
import '../pages/public_room/public_room.dart';
import '../pages/room/room.dart';
import '../pages/room_details/room_details.dart';
import '../pages/room_list/room_list.dart';
import '../pages/room_list/room_list_position_tracker.dart';
import '../pages/share_target/share_target.dart';
import '../pages/splash_screen/splash_screen.dart';
import '../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../pages/user_page/user_page.dart';
import '../pages/user_sessions/user_sessions_page.dart';
import '../widgets/matrix/client_manager/client_store.dart';
import '../widgets/matrix/scopes/matrix_identifier_scope.dart';
import '../widgets/placeholder.dart';
import '../widgets/responsive_layout.dart';
import 'extensions/client_manager_route.dart';
import 'extensions/go_router_path_extension.dart';
import 'extensions/homeserver_uri_route.dart';
import 'extensions/login_state_redirect_route.dart';
import 'extensions/matrix_client_route.dart';
import 'extensions/matrix_deeplink_route.dart';
import 'extensions/must_be_logged_out_route.dart';
import 'extensions/polycule_deeplink_route.dart';
import 'extensions/requires_login_route.dart';
import 'extensions/responsive_shell_route.dart';
import 'extensions/room_available_route.dart';
import 'extensions/room_available_shell_route.dart';
import 'extensions/splash_route.dart';

class PolyculeRouter extends GoRouter {
  factory PolyculeRouter(ValueNotifier<List<Client>> clientNotifier) {
    final routingConfig = ValueNotifier(
      makeRoutingConfig(clientNotifier.value),
    );
    return PolyculeRouter._(routingConfig, clientNotifier);
  }

  PolyculeRouter._(this.routingConfig, this.clientNotifier)
      : super.routingConfig(
          navigatorKey: _applicationNavigatorKey,
          debugLogDiagnostics: kDebugMode,
          routingConfig: routingConfig,
        ) {
    clientNotifier.addListener(_updateRoutingConfig);
  }

  static RoutingConfig makeRoutingConfig(List<Client> clients) => RoutingConfig(
        routes: [
          ClientManagerRoute(
            branches: [
              StatefulShellBranch(
                navigatorKey: GlobalKey<NavigatorState>(),
                routes: [
                  GoRoute(
                    path: FatalErrorPage.routeName,
                    builder: (context, state) =>
                        FatalErrorPage(error: state.extra),
                  ),
                  GoRoute(
                    path: ApplicationSplashScreen.routeName,
                    builder: (context, state) =>
                        const ApplicationSplashScreen(),
                  ),
                  GoRoute(
                    path: AccountSelectorPage.routeName,
                    builder: (context, state) => AccountSelectorPage(
                      redirect: Uri.decodeComponent(
                        state.uri.queryParameters['redirect']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ShareTargetPage.routeName,
                    builder: (context, state) => const ShareTargetPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: GlobalKey<NavigatorState>(),
                routes: [
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
                          GoRoute(
                            path: PushSettingsPage.routeName,
                            builder: (context, state) =>
                                const PushSettingsPage(),
                          ),
                          GoRoute(
                            path: NetworkSettingsPage.routeName,
                            builder: (context, state) =>
                                const NetworkSettingsPage(),
                          ),
                          GoRoute(
                            path: LogsPage.routeName,
                            builder: (context, state) => const LogsPage(),
                          ),
                          GoRoute(
                            path: ErrorReportingSettingsPage.routeName,
                            builder: (context, state) =>
                                const ErrorReportingSettingsPage(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              ...clients.map(makeClientBranch),
            ],
          ),
          PolyculeDeeplinkRoute(),
          MatrixDeeplinkRoute(),
        ],
      );

  static StatefulShellBranch makeClientBranch(Client client) {
    final clientNavigatorKey = GlobalKey<NavigatorState>();
    final roomNavigatorKey = GlobalKey<NavigatorState>();
    final accountSettingsNavigatorKey = GlobalKey<NavigatorState>();
    return StatefulShellBranch(
      navigatorKey: clientNavigatorKey,
      routes: [
        MatrixClientRoute(
          client: client,
          routes: [
            LoginStateRedirectRoute(
              routes: [
                SplashRoute(
                  path: '/client/${client.clientName.clientIdentifier}',
                  builder: (context, state) => const SplashPage(),
                  routes: [
                    MustBeLoggedOutRoute(
                      client: client,
                      path: HomeserverPage.routeName,
                      builder: (context, state) => const HomeserverPage(),
                    ),
                    HomeserverUriRoute(
                      client: client,
                      path: LoginPage.routeName,
                      builder: (context, state, uri) =>
                          LoginPage(homeserver: uri),
                    ),
                    RequiresLoginRoute(
                      client: client,
                      path: SsssBootstrapPage.routeName,
                      builder: (context, state) => SsssBootstrapPage(
                        disableSas: state.uri.queryParameters.containsKey(
                          'disableSas',
                        ),
                      ),
                    ),
                    ResponsiveShellRoute(
                      animateCompactSecondary: true,
                      builder: (context, state) => RoomListPage(
                        key: ValueKey(state.pathParameters['client']),
                      ),
                      routes: [
                        RequiresLoginRoute(
                          client: client,
                          path: RoomListPage.routeName,
                          builder: (context, state) =>
                              const PolyculePlaceholder(),
                          routes: [
                            RoomAvailableShellRoute(
                              client: client,
                              navigatorKey: roomNavigatorKey,
                              builder: (context, state) =>
                                  RoomPage(key: ValueKey(state.uri.fragment)),
                              roomUnavailableBuilder: (context, state) =>
                                  const PublicRoomPage(),
                              routes: [
                                RoomAvailableRoute(
                                  client: client,
                                  path: RoomPage.pathParameter.asGoRouterPath(),
                                  onExit: (context, state) {
                                    final encodedRoomId = state
                                        .pathParameters[RoomPage.pathParameter];
                                    if (encodedRoomId != null) {
                                      final room = client.getRoomById(
                                        Uri.decodeComponent(encodedRoomId),
                                      );
                                      if (room != null) {
                                        RoomListPositionTracker.prepareReturn(
                                          room,
                                        );
                                      }
                                    }
                                    return true;
                                  },
                                  builder: (context, state) =>
                                      const PolyculePlaceholder(),
                                ),
                                RoomAvailableRoute(
                                  client: client,
                                  path: RoomDetailsPage.path,
                                  builder: (context, state) =>
                                      const RoomDetailsPage(),
                                ),
                                RoomAvailableRoute(
                                  client: client,
                                  path: UserPage.roomPath,
                                  builder: (context, state) =>
                                      MatrixIdentifierScope.fromGoRouterState(
                                    state: state,
                                    child: const UserPage(),
                                  ),
                                ),
                                RoomAvailableRoute(
                                  client: client,
                                  path: UserSessionsPage.path,
                                  builder: (context, state) =>
                                      MatrixIdentifierScope.fromGoRouterState(
                                    state: state,
                                    child: const UserSessionsPage(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GoRoute(
                          path: '/user',
                          redirect: (context, state) => state.uri.path
                              .substring(0, state.uri.path.lastIndexOf('/')),
                        ),
                        RequiresLoginRoute(
                          client: client,
                          path: UserPage.makeRouteName(),
                          builder: (context, state) =>
                              MatrixIdentifierScope.fromGoRouterState(
                            state: state,
                            child: const UserPage(),
                          ),
                        ),
                      ],
                    ),
                    ShellRoute(
                      navigatorKey: accountSettingsNavigatorKey,
                      builder: (context, state, child) =>
                          AccountSettingsBackHandler(
                        uri: state.uri,
                        nestedNavigatorKey: accountSettingsNavigatorKey,
                        child: ResponsiveLayout(
                          uri: state.uri,
                          main: const AccountSettings(),
                          secondary: child,
                        ),
                      ),
                      routes: [
                        RequiresLoginRoute(
                          client: client,
                          path: AccountSettings.routeName,
                          builder: (context, state) =>
                              const PolyculePlaceholder(),
                          routes: [
                            RequiresLoginRoute(
                              client: client,
                              path: EmojiSettingsPage.routeName,
                              builder: (context, state) =>
                                  const EmojiSettingsPage(),
                            ),
                            RequiresLoginRoute(
                              client: client,
                              path: SessionSettingsPage.routeName,
                              builder: (context, state) =>
                                  const SessionSettingsPage(),
                            ),
                            RequiresLoginRoute(
                              client: client,
                              path: NotificationSettingsPage.routeName,
                              builder: (context, state) =>
                                  const NotificationSettingsPage(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static final _applicationNavigatorKey = GlobalKey<NavigatorState>();

  final ValueNotifier<List<Client>> clientNotifier;
  final ValueNotifier<RoutingConfig> routingConfig;

  @override
  void dispose() {
    clientNotifier.removeListener(_updateRoutingConfig);
    super.dispose();
  }

  void _updateRoutingConfig() =>
      routingConfig.value = makeRoutingConfig(clientNotifier.value);
}
