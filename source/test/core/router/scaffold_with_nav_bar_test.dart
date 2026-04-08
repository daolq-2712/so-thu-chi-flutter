import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:so_thu_chi/core/router/scaffold_with_nav_bar.dart';
import 'package:so_thu_chi/features/home/presentation/pages/home_page.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/settings_page.dart';
import 'package:so_thu_chi/features/transaction/presentation/pages/add_transaction_page.dart';
import 'package:so_thu_chi/l10n/app_localizations.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
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
  });

  tearDown(() {
    router.dispose();
  });

  Widget createTestApp({Locale? locale}) {
    return MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      routerConfig: router,
    );
  }

  group('Navigation Shell Tests', () {
    testWidgets('App launches to Home with selectedIndex 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify Home page is visible
      expect(find.byKey(const Key('page_home')), findsOneWidget);

      // Verify NavigationBar selectedIndex is 0
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('Tap Settings tab navigates to Settings with selectedIndex 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Find and tap Settings destination
      final settingsDestination = find
          .descendant(
            of: find.byType(NavigationBar),
            matching: find.byType(NavigationDestination),
          )
          .at(1);
      await tester.tap(settingsDestination);
      await tester.pumpAndSettle();

      // Verify Settings page is visible
      expect(find.byKey(const Key('page_settings')), findsOneWidget);

      // Verify NavigationBar selectedIndex is 1
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1);
    });

    testWidgets('Tap Home tab navigates to Home with selectedIndex 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // First navigate to Settings
      final settingsDestination = find
          .descendant(
            of: find.byType(NavigationBar),
            matching: find.byType(NavigationDestination),
          )
          .at(1);
      await tester.tap(settingsDestination);
      await tester.pumpAndSettle();

      // Then tap Home destination
      final homeDestination = find
          .descendant(
            of: find.byType(NavigationBar),
            matching: find.byType(NavigationDestination),
          )
          .at(0);
      await tester.tap(homeDestination);
      await tester.pumpAndSettle();

      // Verify Home page is visible
      expect(find.byKey(const Key('page_home')), findsOneWidget);

      // Verify NavigationBar selectedIndex is 0
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });
  });

  group('FAB Navigation Tests', () {
    testWidgets('From Home, tap FAB navigates to Add Transaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify we're on Home
      expect(find.byKey(const Key('page_home')), findsOneWidget);

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify Add Transaction page is visible
      expect(find.byKey(const Key('page_add_transaction')), findsOneWidget);
    });

    testWidgets('From Settings, tap FAB navigates to Add Transaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Settings
      final settingsDestination = find
          .descendant(
            of: find.byType(NavigationBar),
            matching: find.byType(NavigationDestination),
          )
          .at(1);
      await tester.tap(settingsDestination);
      await tester.pumpAndSettle();

      // Verify we're on Settings
      expect(find.byKey(const Key('page_settings')), findsOneWidget);

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify Add Transaction page is visible
      expect(find.byKey(const Key('page_add_transaction')), findsOneWidget);
    });
  });

  group('Return to Previous Tab Tests', () {
    testWidgets('Home → FAB → back → returns to Home', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify we're on Home (selectedIndex 0)
      expect(find.byKey(const Key('page_home')), findsOneWidget);
      var navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we're on Add Transaction
      expect(find.byKey(const Key('page_add_transaction')), findsOneWidget);

      // Pop back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on Home
      expect(find.byKey(const Key('page_home')), findsOneWidget);
      navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('Settings → FAB → back → returns to Settings', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Settings
      final settingsDestination = find
          .descendant(
            of: find.byType(NavigationBar),
            matching: find.byType(NavigationDestination),
          )
          .at(1);
      await tester.tap(settingsDestination);
      await tester.pumpAndSettle();

      // Verify we're on Settings (selectedIndex 1)
      expect(find.byKey(const Key('page_settings')), findsOneWidget);
      var navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1);

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we're on Add Transaction
      expect(find.byKey(const Key('page_add_transaction')), findsOneWidget);

      // Pop back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on Settings
      expect(find.byKey(const Key('page_settings')), findsOneWidget);
      navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 1);
    });
  });

  group('Bottom Nav Visibility Tests', () {
    testWidgets('NavigationBar visible on Home', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_home')), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('NavigationBar visible on Settings', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to Settings
      final settingsDestination = find
          .descendant(
            of: find.byType(NavigationBar),
            matching: find.byType(NavigationDestination),
          )
          .at(1);
      await tester.tap(settingsDestination);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_settings')), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('NavigationBar NOT visible on Add Transaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap FAB to navigate to Add Transaction
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_add_transaction')), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });

  group('Localization Tests', () {
    testWidgets('English locale shows correct labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('en')));
      await tester.pumpAndSettle();

      // Find NavigationDestination widgets
      final destinations = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(NavigationDestination),
      );

      final homeDestination = tester.widget<NavigationDestination>(
        destinations.at(0),
      );
      final settingsDestination = tester.widget<NavigationDestination>(
        destinations.at(1),
      );

      expect(homeDestination.label, 'Home');
      expect(settingsDestination.label, 'Settings');
    });

    testWidgets('Vietnamese locale shows correct labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Find NavigationDestination widgets
      final destinations = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(NavigationDestination),
      );

      final homeDestination = tester.widget<NavigationDestination>(
        destinations.at(0),
      );
      final settingsDestination = tester.widget<NavigationDestination>(
        destinations.at(1),
      );

      expect(homeDestination.label, 'Sổ giao dịch');
      expect(settingsDestination.label, 'Cài đặt');
    });
  });

  group('Accessibility Tests', () {
    testWidgets('FAB has tooltip with localized text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.tooltip, 'Add Transaction');
    });

    testWidgets('NavigationDestination widgets have non-empty labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final destinations = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(NavigationDestination),
      );

      final homeDestination = tester.widget<NavigationDestination>(
        destinations.at(0),
      );
      final settingsDestination = tester.widget<NavigationDestination>(
        destinations.at(1),
      );

      expect(homeDestination.label, isNotEmpty);
      expect(settingsDestination.label, isNotEmpty);
    });
  });
}
