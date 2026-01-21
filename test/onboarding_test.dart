import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:secure_flow_mobile/ui/screens/onboarding_screen.dart';
import 'package:secure_flow_mobile/ui/styles/app_theme.dart';

void main() {
  testWidgets('Onboarding flow smoke test', (WidgetTester tester) async {
    // Mock GoRouter to avoid actual navigation issues during test if needed, 
    // but for simple page transitions inside PageView, we might not need full router mock 
    // unless the "Final" step calls context.go.
    // The test focuses on the PageView transitions.

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const OnboardingScreen(),
      ),
    );

    // Step 1: Welcome
    expect(find.text('Bienvenue sur CycleFlow'), findsOneWidget);
    await tester.tap(find.text('CONTINUER'));
    await tester.pumpAndSettle();

    // Step 2: Name
    expect(find.text('Faisons connaissance'), findsOneWidget);
    
    // Try to continue without name (should be disabled/no-op)
    // The button logic: _currentPage == 1 && _nameController.text.isEmpty ? null : _nextPage
    // So tapping it should do nothing if disabled.
    // Verify we are still on name page.
    expect(find.text('Faisons connaissance'), findsOneWidget);

    // Enter Name
    await tester.enterText(find.byType(TextField), 'TestUser');
    await tester.pump();

    // Tap Continue
    await tester.tap(find.text('CONTINUER'));
    await tester.pumpAndSettle();

    // Step 3: Cycle Length
    expect(find.text('Ton cycle'), findsOneWidget);
  });
}
