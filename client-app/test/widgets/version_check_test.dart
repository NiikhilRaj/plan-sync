import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/version_controller.dart';
import 'package:plan_sync/widgets/version_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../mock_controllers/version_controller_mock.dart';

void main() {
  Future<void> pumpBaseWidget(WidgetTester tester) async {
    return tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: VersionCheckWidget(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets('VersionCheckWidget renders when update is available',
      (WidgetTester tester) async {
    final controller = Get.find<VersionController>() as MockVersionController;
    controller.updateResult = true;

    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.text('Update Available'), findsOneWidget);
    expect(find.text('Update Now'), findsOneWidget);
    expect(find.byIcon(Icons.download_rounded), findsOneWidget);
  });

  testWidgets('VersionCheckWidget renders when update is available',
      (WidgetTester tester) async {
    final controller = Get.find<VersionController>() as MockVersionController;
    controller.updateResult = false;

    await pumpBaseWidget(tester);
    await tester.pumpAndSettle();

    expect(find.text('Update Available'), findsNothing);
    expect(find.text('Update Now'), findsNothing);
    expect(find.byIcon(Icons.download_rounded), findsNothing);
  });
}
