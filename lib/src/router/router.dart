import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:go_router/go_router.dart';

import '../pages/account_selector/account_selector.dart';
import '../pages/account_settings/account_settings.dart';
import '../pages/account_settings/pages/emoji_settings/emoji_settings.dart';
import '../pages/account_settings/pages/notification_settings/notification_settings.dart';
import '../pages/account_settings/pages/session_settings/session_settings.dart';
import '../pages/application_settings/application_settings.dart';
import '../pages/application_settings/pages/appearance.dart';
import '../pages/application_settings/pages/error_reporting.dart';
import '../pages/application_settings/pages/logs.dart';
import '../pages/application_settings/pages/network.dart';
import '../pages/application_settings/pages/push.dart';
import '../pages/fatal_error/fatal_error_page.dart';
import '../pages/homeserver/homeserver.dart';
import '../pages/login/login.dart';
import '../pages/public_room/public_room.dart';
import '../pages/room/room.dart';
import '../pages/room_details/room_details.dart';
import '../pages/room_list/room_list.dart';
import '../pages/splash_screen/splash_screen.dart';
import '../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../pages/user_page/user_page.dart';
import '../pages/user_sessions/user_sessions_page.dart';
import '../widgets/matrix/scopes/matrix_identifier_scope.dart';
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
import 'extensions/room_available_shell_route.dart';
import 'extensions/splash_route.dart';

class PolyculeRouter extends GoRouter {
  PolyculeRouter()
      : super.routingConfig(
          navigatorKey: _applicationNavigatorKey,
          debugLogDiagnostics: kDebugMode,
          routingConfig: ValueNotifier(config),
        );

  static final config = RoutingConfig(
    routes: [
      GoRoute(
        path: FatalErrorPage.routeName,
        builder: (context, state) => FatalErrorPage(error: state.extra),
      ),
      PolyculeDeeplinkRoute(),
      MatrixInjectedRoute(
        navigatorKey: PolyculeRouter._matrixNavigatorKey,
        routes: [
          // in order to handle `/`
          GoRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: SplashPage.routeName,
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: FatalErrorPage.routeName.asMultiClientRoute(),
            builder: (context, state) => FatalErrorPage(error: state.extra),
          ),
          // in order to initialize particular client
          SplashRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: SplashPage.routeName.asMultiClientRoute(),
            builder: (context, state) => SplashPage(
              key: ValueKey(state.uri.toString()),
            ),
          ),
          GoRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: AccountSelectorPage.routeName,
            builder: (context, state) => AccountSelectorPage(
              redirect: Uri.decodeComponent(
                state.uri.queryParameters['redirect']!,
              ),
            ),
          ),
          ResponsiveShellRoute(
            // parentNavigatorKey: PolyculeRouter._applicationNavigatorKey,
            builder: (context, state) => const ApplicationSettingsPage(),
            routes: [
              GoRoute(
                path: ApplicationSettingsPage.routeName,
                builder: (context, state) => const PolyculePlaceholder(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: PolyculeRouter._applicationNavigatorKey,
                    path: AppearanceSettingsPage.routeName,
                    builder: (context, state) => const AppearanceSettingsPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: PolyculeRouter._applicationNavigatorKey,
                    path: PushSettingsPage.routeName,
                    builder: (context, state) => const PushSettingsPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: PolyculeRouter._applicationNavigatorKey,
                    path: NetworkSettingsPage.routeName,
                    builder: (context, state) => const NetworkSettingsPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: PolyculeRouter._applicationNavigatorKey,
                    path: LogsPage.routeName,
                    builder: (context, state) => const LogsPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: PolyculeRouter._applicationNavigatorKey,
                    path: ErrorReportingSettingsPage.routeName,
                    builder: (context, state) =>
                        const ErrorReportingSettingsPage(),
                  ),
                ],
              ),
            ],
          ),
          MustBeLoggedOutRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: HomeserverPage.routeName.asMultiClientRoute(),
            builder: (context, state) => const HomeserverPage(),
          ),
          HomeserverUriRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: LoginPage.routeName.asMultiClientRoute(),
            builder: (context, state, uri) => LoginPage(homeserver: uri),
          ),
          RequiresLoginRoute(
            parentNavigatorKey: PolyculeRouter._matrixNavigatorKey,
            path: SsssBootstrapPage.routeName.asMultiClientRoute(),
            builder: (context, state) => SsssBootstrapPage(
              disableSas: state.uri.queryParameters.containsKey(
                'disableSas',
              ),
            ),
          ),
          ResponsiveShellRoute(
            navigatorKey: PolyculeRouter._tabNavigatorKey,
            builder: (context, state) => RoomListPage(
              key: ValueKey(state.pathParameters['client']),
            ),
            routes: [
              RequiresLoginRoute(
                path: RoomListPage.routeName.asMultiClientRoute(),
                builder: (context, state) => const PolyculePlaceholder(),
                routes: [
                  RoomAvailableShellRoute(
                    builder: (context, state) => const RoomPage(),
                    roomUnavailableBuilder: (
                      context,
                      state,
                      filter,
                      via,
                      action,
                      eventId,
                    ) =>
                        PublicRoomPage(
                      filter: filter,
                      via: via,
                      action: action,
                      eventId: eventId,
                    ),
                    routes: [
                      RoomAvailableRoute(
                        path: RoomPage.pathParameter.asGoRouterPath(),
                        builder: (context, state) =>
                            const PolyculePlaceholder(),
                      ),
                      RoomAvailableRoute(
                        path: RoomDetailsPage.path,
                        builder: (context, state) => const RoomDetailsPage(),
                      ),
                      RoomAvailableRoute(
                        path: UserPage.roomPath,
                        builder: (context, state) =>
                            MatrixIdentifierScope.fromGoRouterState(
                          state: state,
                          child: const UserPage(),
                        ),
                      ),
                      RoomAvailableRoute(
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
                path: '/user'.asMultiClientRoute(),
                redirect: (context, state) => state.uri.path
                    .substring(0, state.uri.path.lastIndexOf('/')),
              ),
              RequiresLoginRoute(
                path: UserPage.makeRouteName().asMultiClientRoute(),
                builder: (context, state) =>
                    MatrixIdentifierScope.fromGoRouterState(
                  state: state,
                  child: const UserPage(),
                ),
              ),
            ],
          ),
          ResponsiveShellRoute(
            // navigatorKey: PolyculeRouter._tabNavigatorKey,
            builder: (context, state) => const AccountSettings(),
            routes: [
              RequiresLoginRoute(
                path: AccountSettings.routeName.asMultiClientRoute(),
                builder: (context, state) => const PolyculePlaceholder(),
                routes: [
                  RequiresLoginRoute(
                    path: EmojiSettingsPage.routeName,
                    builder: (context, state) => const EmojiSettingsPage(),
                  ),
                  RequiresLoginRoute(
                    path: SessionSettingsPage.routeName,
                    builder: (context, state) => const SessionSettingsPage(),
                  ),
                  RequiresLoginRoute(
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
      MatrixDeeplinkRoute(),
    ],
  );

  static final _applicationNavigatorKey = GlobalKey<NavigatorState>();
  static final _matrixNavigatorKey = GlobalKey<NavigatorState>();
  static final _tabNavigatorKey = GlobalKey<NavigatorState>();
}
