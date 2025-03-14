import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:plan_sync/controllers/filter_controller.dart';
import 'package:plan_sync/controllers/git_service.dart';
import 'package:plan_sync/util/logger.dart';
import 'package:provider/provider.dart';

class SemesterBar extends StatefulWidget {
  const SemesterBar({super.key});

  @override
  State<SemesterBar> createState() => _SemesterBarState();
}

class _SemesterBarState extends State<SemesterBar> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: colorScheme.onSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: 128,
        height: 48,
        child: DropdownButtonHideUnderline(
          child: Consumer<GitService>(builder: (ctx, serviceController, child) {
            return Consumer<FilterController>(
                builder: (ctx, filterController, child) {
              return DropdownButton<String>(
                isExpanded: true,
                elevation: 0,
                enableFeedback: true,
                style: TextStyle(color: colorScheme.onSurface),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.surface,
                ),
                value: filterController.activeSemester,
                dropdownColor: colorScheme.onSurface,
                menuMaxHeight: 256,
                disabledHint: Text(
                  "Select Year First",
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 16,
                  ),
                ),
                hint: serviceController.semesters == null
                    ? LoadingAnimationWidget.progressiveDots(
                        color: colorScheme.onPrimary,
                        size: 18,
                      )
                    : Text(
                        "Semester",
                        style: TextStyle(
                          color: colorScheme.surface,
                          fontSize: 16,
                        ),
                      ),
                items: serviceController.semesters
                    ?.map((e) => _buildMenuItem(e, colorScheme.surface))
                    .toList(),
                onChanged: (String? newSelection) {
                  Logger.i("new semester: $newSelection");
                  filterController.activeSemester = newSelection;
                },
              );
            });
          }),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> _buildMenuItem(String semester, Color color) {
  return DropdownMenuItem(
    value: semester,
    child: Text(
      semester,
      style: TextStyle(color: color),
    ),
  );
}
