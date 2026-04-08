import 'package:go_router/go_router.dart';
import 'package:so_thu_chi/core/router/scaffold_with_nav_bar.dart';
import 'package:so_thu_chi/features/home/presentation/pages/home_page.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/categories_page.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/language_page.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/settings_page.dart';
import 'package:so_thu_chi/features/transaction/presentation/pages/add_transaction_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'language',
                  builder: (context, state) => const LanguagePage(),
                ),
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const CategoriesPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionPage(),
    ),
  ],
);
