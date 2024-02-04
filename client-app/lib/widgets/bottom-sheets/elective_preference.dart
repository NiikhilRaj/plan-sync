import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plan_sync/widgets/dropdowns/electives_scheme_bar.dart';
import 'package:plan_sync/widgets/dropdowns/electives_sem_bar.dart';
import 'package:plan_sync/widgets/dropdowns/elective_year_bar.dart';
import 'package:plan_sync/util/snackbar.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:get/get.dart';

class ElectivePreferenceBottomSheet extends StatefulWidget {
  const ElectivePreferenceBottomSheet({this.save = false, super.key});

  final bool save;

  @override
  State<ElectivePreferenceBottomSheet> createState() =>
      ElectivePreferenceBottomSheetState();
}

@visibleForTesting
class ElectivePreferenceBottomSheetState
    extends State<ElectivePreferenceBottomSheet> {
  late bool savePreferencesOnExit;

  @override
  void initState() {
    super.initState();
    savePreferencesOnExit = widget.save;
  }

  void exitBottomSheet() {
    if (savePreferencesOnExit) {
      FilterController controller = Get.find();
      controller.storePrimaryElectiveYear();
      controller.storePrimaryElectiveSemester();
      controller.storePrimaryElectiveScheme();
      CustomSnackbar.info(
        'Primary Preferences Stored!',
        "Your timetable will be selected by default.",
      );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          left: size.width * 0.04,
          right: size.width * 0.04,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 16),

              // top drag handle
              Container(
                height: 8,
                width: size.width * 0.24,
                decoration: ShapeDecoration(
                  color: colorScheme.onBackground,
                  shape: const StadiumBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // preference switch
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.downloading_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  "Save Preferences",
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                trailing: Switch.adaptive(
                  value: savePreferencesOnExit,
                  activeTrackColor: colorScheme.secondary.withOpacity(0.72),
                  inactiveTrackColor: Colors.transparent,

                  // will be fixed by https://github.com/opxdelwin/plan-sync/issues/19
                  onChanged: (value) {
                    setState(() {
                      savePreferencesOnExit = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),

              // preference description
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * 0.04,
                  right: size.width * 0.04,
                ),
                child: Text(
                  'We will store these, so that  next time you open Plan Sync, your classes are selected automatically!',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Program selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  'Program',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                trailing: Text(
                  'BTech.',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),

              // year selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  'Year',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                trailing: const ElectiveYearBar(),
              ),

              // semester selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  'Semester',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                trailing: const ElectiveSemesterBar(),
              ),

              // section selection
              ListTile(
                enableFeedback: true,
                leading: Icon(
                  Icons.book_rounded,
                  color: colorScheme.onPrimary,
                ),
                title: Text(
                  'Scheme',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                  ),
                ),
                trailing: const ElectiveSchemeBar(),
              ),
              const SizedBox(height: 32),

              // save and exit button
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(colorScheme.secondary),
                  foregroundColor:
                      MaterialStatePropertyAll(colorScheme.onSecondary),
                  padding: MaterialStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  ),
                ),
                onPressed: exitBottomSheet,
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: colorScheme.background,
                  ),
                ),
              ),
              const SizedBox(height: 16)
            ],
          ),
        ),
      ),
    );
  }
}
