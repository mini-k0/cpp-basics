import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcoach_ai/main.dart';

void main() {
  testWidgets('FitCoach AI 홈 화면 테스트', (tester) async {
    await tester.pumpWidget(const FitCoachApp());

    expect(find.text('FitCoach AI'), findsOneWidget);
    expect(find.text('운동 기록'), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });
}