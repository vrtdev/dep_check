import 'dart:io';

import 'models.dart';

class Printer {
  Printer._();

  static void printOutput(final Output output) {
    final outputStr = StringBuffer()
      ..writeln()
      ..writeln("Dependencies Check:")
      ..writeln("-------------------");

    if (output.upToDateDependencies.isNotEmpty) {
      outputStr.writeln("Up to date:");

      output.upToDateDependencies
        ..sort()
        ..forEach((upToDateDep) {
          outputStr.writeln("✅  ${upToDateDep.name}");
        });
    }

    if (output.pubUpgradeableDependencies.isNotEmpty) {
      outputStr
        ..writeln()
        ..writeln("Pub upgradeablable (run `flutter pub upgrade`)");

      output.pubUpgradeableDependencies
        ..sort()
        ..forEach((pubUpgradeableDep) {
          outputStr.writeln(
              "⏫ ${pubUpgradeableDep.name} - ${pubUpgradeableDep.currentVersion} ➡️ ${pubUpgradeableDep.latestVersion}");
        });
    }

    if (output.manualUpdatableDependencies.isNotEmpty) {
      outputStr..writeln()..writeln("Manually upgradable");

      output.manualUpdatableDependencies
        ..sort()
        ..forEach((depToUpdateManually) {
          outputStr.writeln(
              "👆 ${depToUpdateManually.name} - ${depToUpdateManually.currentVersion} ➡️ ${depToUpdateManually.latestVersion}");
        });
    }

    stdout.writeln(outputStr.toString());
  }
}
