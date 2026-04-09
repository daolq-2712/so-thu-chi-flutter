import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/categories_page.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/language_page.dart';
import 'package:so_thu_chi/features/settings/presentation/pages/settings_page.dart';
import 'package:so_thu_chi/l10n/app_localizations.dart';

void main() {
  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/settings',
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
    );
  }

  Widget buildApp(GoRouter router, {Locale? locale}) {
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

  group('SettingsPage', () {
    testWidgets('shows exactly two tiles in expected order', (tester) async {
      final router = buildRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tile_language')), findsOneWidget);
      expect(find.byKey(const Key('tile_categories')), findsOneWidget);

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles.length, 2);
      expect((listTiles.first.title as Text).data, 'Language');
      expect((listTiles.last.title as Text).data, 'Manage Categories');
    });

    testWidgets('navigates to /settings/language when tapping language tile', (
      tester,
    ) async {
      final router = buildRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(buildApp(router, locale: const Locale('vi')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tile_language')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_language')), findsOneWidget);
      expect(router.state.uri.path, '/settings/language');
    });

    testWidgets(
      'navigates to /settings/categories when tapping manage categories tile',
      (tester) async {
        final router = buildRouter();
        addTearDown(router.dispose);

        await tester.pumpWidget(buildApp(router, locale: const Locale('vi')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('tile_categories')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('page_categories')), findsOneWidget);
        expect(router.state.uri.path, '/settings/categories');
      },
    );

    testWidgets('localizes labels in English and Vietnamese', (tester) async {
      final enRouter = buildRouter();
      addTearDown(enRouter.dispose);

      await tester.pumpWidget(buildApp(enRouter, locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Manage Categories'), findsOneWidget);

      final viRouter = buildRouter();
      addTearDown(viRouter.dispose);
      await tester.pumpWidget(buildApp(viRouter, locale: const Locale('vi')));
      await tester.pumpAndSettle();

      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Quản lý thể loại'), findsOneWidget);
    });

    testWidgets('each tile has touch target height >= 48dp', (tester) async {
      final router = buildRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      final tiles = find.byType(ListTile);
      expect(tiles, findsNWidgets(2));

      for (var i = 0; i < 2; i++) {
        final size = tester.getSize(tiles.at(i));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('rapid repeated taps do not crash app', (tester) async {
      final router = buildRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('tile_language')));
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
