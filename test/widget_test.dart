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

  testWidgets('App boots to auth gate safely', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: UniTaskApp()));
    await tester.pump(); // first frame
    await pumpFrames(tester, frames: 10);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
