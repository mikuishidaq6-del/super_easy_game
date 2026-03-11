// This is a basic Flutter widget test for the super_easy_game app.

import 'package:flutter_test/flutter_test.dart';

import 'package:super_easy_game/models/game_models.dart';

void main() {
  testWidgets('App smoke test: FaceScale enum is accessible', (WidgetTester tester) async {
    expect(FaceScale.values.length, 5);
  });
}
