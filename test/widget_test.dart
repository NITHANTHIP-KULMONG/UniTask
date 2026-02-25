import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:unitask/app.dart';

void main() {
  Future<void> pumpFrames(WidgetTester tester, {int frames = 10}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Finder _homeShellScaffoldFinder() {
    // Anchor from the single bottom NavigationBar, then grab its nearest Scaffold ancestor.
    final navBar = find.byType(NavigationBar);
    expect(navBar, findsOneWidget);

    final scaffold = find.ancestor(
      of: navBar,
      matching: find.byType(Scaffold),
    );

    // There should be exactly one Scaffold that owns the NavigationBar (HomeShell scaffold).
    expect(scaffold, findsOneWidget);
    return scaffold;
  }

  void expectHomeShellAppBarTitle(WidgetTester tester, String title) {
    final homeScaffold = _homeShellScaffoldFinder();

    final appBar = find.descendant(
      of: homeScaffold,
      matching: find.byType(AppBar),
    );
    expect(appBar, findsOneWidget);

    expect(
      find.descendant(of: appBar, matching: find.text(title)),
      findsOneWidget,
    );
  }

  testWidgets('App boots + bottom-nav smoke navigation (no pumpAndSettle)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UniTaskApp()));
    await tester.pump(); // first frame
    await pumpFrames(tester, frames: 10);

    // Default selected tab is Tasks (index=1).
    expectHomeShellAppBarTitle(tester, 'Assignments');

    Future<void> goToTab(IconData icon, String expectedAppBarTitle) async {
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);

      final iconInNavBar = find.descendant(of: navBar, matching: find.byIcon(icon));
      expect(iconInNavBar, findsAtLeastNWidgets(1));

      await tester.tap(iconInNavBar.first);
      await tester.pump(); // start nav animation
      await pumpFrames(tester, frames: 12);

      expectHomeShellAppBarTitle(tester, expectedAppBarTitle);
    }

    await goToTab(Icons.dashboard_outlined, 'Dashboard');
    await goToTab(Icons.checklist_outlined, 'Assignments');
    await goToTab(Icons.timer_outlined, 'Timer');
    await goToTab(Icons.book_outlined, 'Subjects');
    await goToTab(Icons.dashboard_outlined, 'Dashboard');
  });
}