import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/establishments/screens/establishments_screen.dart';
import '../../features/sites/screens/sites_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../screens/favorites_screen.dart';
import '../../screens/search_results_screen.dart';
import '../../screens/establishment_detail_screen.dart';
import '../../screens/site_detail_screen.dart';
import '../../screens/language_settings_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String home = '/';
  static const String establishments = '/establishments';
  static const String sites = '/sites';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String search = '/search';
  static const String establishmentDetail = '/establishment';
  static const String siteDetail = '/site';
  static const String languageSettings = '/language-settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: establishments,
            name: 'establishments',
            builder: (context, state) => const EstablishmentsScreen(),
          ),
          GoRoute(
            path: sites,
            name: 'sites',
            builder: (context, state) => const SitesScreen(),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: favorites,
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
        ],
      ),
      
      // Authentication Routes (outside main shell)
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(token: token);
        },
      ),
      
      // Search Results
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SearchResultsScreen(
            query: extra['query'] as String?,
            categoryId: extra['categoryId'] as String?,
            categoryName: extra['categoryName'] as String?,
          );
        },
      ),
      
      // Establishment Detail
      GoRoute(
        path: '$establishmentDetail/:id',
        name: 'establishment-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EstablishmentDetailScreen(establishmentId: id);
        },
      ),
      
      // Site Detail
      GoRoute(
        path: '$siteDetail/:id',
        name: 'site-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SiteDetailScreen(siteId: id);
        },
      ),
      
      // Language Settings
      GoRoute(
        path: languageSettings,
        name: 'language-settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
    ],
  );
}
