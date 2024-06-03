import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plan_sync/util/external_links.dart';

class ContributeScheduleBottomSheet extends StatelessWidget {
  const ContributeScheduleBottomSheet({super.key});

  void launchMail() {
    ExternalLinks.contributeTimeTableViaMail();
  }

  void launchGithub() {
    ExternalLinks.contributeTimeTableViaGithub();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // via mail
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contribute via mail",
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(colorScheme.onSurface),
                  ),
                  onPressed: () => launchMail(),
                  child: Row(
                    children: [
                      Text(
                        'Launch Mail',
                        style: TextStyle(
                          color: colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.mail_outline_rounded,
                        color: colorScheme.background,
                      )
                    ],
                  ))
            ],
          ),

          // via github
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contribute via GitHub",
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStatePropertyAll(colorScheme.onSurface),
                  ),
                  onPressed: () => launchGithub(),
                  child: Row(
                    children: [
                      Text(
                        'Launch GitHub',
                        style: TextStyle(
                          color: colorScheme.background,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        FontAwesomeIcons.github,
                        color: colorScheme.background,
                      )
                    ],
                  ))
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
