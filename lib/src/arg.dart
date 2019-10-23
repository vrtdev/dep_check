import 'dart:io';

import 'package:args/args.dart';

import 'models.dart';

class CLIArgParser {
  CLIArgParser._();

  static const _defaultPubSpecLocation = "pubspec.yaml";
  static const _pubSpecKey = "pubspec";

  static const _defaultPubSpecLockLocation = "pubspec.lock";
  static const _pubLockKey = "lock";

  static final _cliParser = ArgParser()
    ..addSeparator("===== pubspec.yaml")
    ..addOption(
      _pubSpecKey,
      abbr: 'p',
      defaultsTo: _defaultPubSpecLocation,
      help: 'Location of your pubspec.yaml file',
    )
    ..addSeparator('===== pubspec.lock')
    ..addOption(
      _pubLockKey,
      abbr: 'l',
      defaultsTo: _defaultPubSpecLockLocation,
      help: 'Location of your pubspec.lock file',
    );

  static Input fromRawArgs(final List<String> args) {
    final results = _cliParser.parse(args);
    return Input(
      results[_pubSpecKey],
      results[_pubLockKey],
    );
  }

  static void printUsage() => stdout.writeln(_cliParser.usage);
}
