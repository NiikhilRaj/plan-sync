import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/widgets/dropdowns/electives_scheme_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../mock_controllers/filter_controller_mock.dart';
import '../../mock_controllers/git_service_mock.dart';

void main() {
  Future<void> pumpBaseWidget(
    WidgetTester tester,
  ) async {
    return tester.pumpWidget(const GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: ElectiveSchemeBar(),
        ),
      ),
    ));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    injectMockDependencies();
  });

  testWidgets(
    'ElectiveSchemeBar loads when no data',
    (WidgetTester tester) async {
      // initial state
      await pumpBaseWidget(tester);
      await tester.pumpAndSettle();
      expect(find.text('Select Semester First'), findsOneWidget);
    },
  );

  testWidgets(
    'ElectiveSchemeBar loads when data is availble but not selected',
    (WidgetTester tester) async {
      final gitController = Get.find<GitService>() as MockGitService;
      final filterController =
          Get.find<FilterController>() as MockFilterController;

      filterController.activeElectiveSemester = "SEM1";
      gitController.electiveSchemes = {
        "a": "Scheme A",
        "b": "Scheme B",
      }.obs;

      // initial state
      await pumpBaseWidget(tester);
      await tester.pumpAndSettle();
      expect(find.text('Scheme'), findsOneWidget);
    },
  );

  testWidgets(
    'ElectiveSchemeBar updates data when clicked on item',
    (WidgetTester tester) async {
      final gitController = Get.find<GitService>() as MockGitService;
      final filterController =
          Get.find<FilterController>() as MockFilterController;

      filterController.activeElectiveSemester = "SEM1";
      gitController.electiveSchemes = {
        "a": "Scheme A",
        "b": "Scheme B",
      }.obs;

      // initial state
      await pumpBaseWidget(tester);
      await tester.pumpAndSettle();
      expect(find.text('Scheme'), findsOneWidget);

      // enabled state with dropdown items
      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      // check if supplied data is found
      expect(find.byType(DropdownMenuItem<String>), findsExactly(2));

      await tester.tap(find.text("Scheme A"));
      await tester.pumpAndSettle();

      // check if controller value updates
      expect(filterController.activeElectiveScheme, "Scheme A");
    },
  );
}
