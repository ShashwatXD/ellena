import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

const accountMenuItems = <({IconData icon, String label})>[
  (icon: Icons.schedule_rounded, label: AppConstants.settingsScheduledTasks),
  (icon: Icons.lightbulb_outline_rounded, label: AppConstants.settingsKnowledge),
  (icon: Icons.mail_outline_rounded, label: AppConstants.settingsMail),
  (icon: Icons.storage_outlined, label: AppConstants.settingsDataControls),
  (icon: Icons.web_asset_rounded, label: AppConstants.settingsCloudBrowser),
  (icon: Icons.extension_outlined, label: AppConstants.settingsSkills),
  (icon: Icons.power_outlined, label: AppConstants.settingsConnectors),
  (
    icon: Icons.electrical_services_outlined,
    label: AppConstants.settingsIntegrations
  ),
];
