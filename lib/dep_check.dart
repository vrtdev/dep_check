library dep_check;

import 'dart:io';

import 'package:dep_check/src/arg.dart';
import 'package:dep_check/src/comparator.dart';
import 'package:dep_check/src/file.dart';
import 'package:dep_check/src/models.dart';
import 'package:dep_check/src/printer.dart';
import 'package:dep_check/src/pub.dart';

void checkDependencies(final List<String> args) async {
  try {
    final cliArgs = CLIArgParser.fromRawArgs(args);
    final FileContents fileContents =
        await FileHelper.readFileContents(cliArgs);
    final List<ResolvedDependency> latestVersions =
        await PubService.lastVersions(
            fileContents.yamlContents.allDependencies);

    final output = Comparator.compareVersions(
      CompareInput(
        fileContents.yamlContents.allDependencies,
        fileContents.lockContents.resolvedDependencies,
        latestVersions,
      ),
    );

    Printer.printOutput(output);
    exit(0);
  } catch (e) {
    stderr.writeln(e);
    CLIArgParser.printUsage();
    exit(1);
  }
}
