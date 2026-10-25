import "package:flutter_test/flutter_test.dart";
import "package:common_beats_flutter/main.dart";

void main() {
  testWidgets("999 Common Beats app builds", (tester) async {
    await tester.pumpWidget(const CommonBeatsApp());
    await tester.pump();
    expect(find.byType(CommonBeatsApp), findsOneWidget);
  });
}
