import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'models.dart';

class FileHelper {
  FileHelper._();

  static const depKey = "dependencies";
  static const devDepKey = "dev_dependencies";
  static const resolvedPackagesKey = "packages";
  static const resolvedVersionKey = "version";

  static Future<FileContents> readFileContents(final Input args) async {
    final pubSpecYamlFile = File(args.pathToPubSpec);
    final pubLockFile = File(args.pathToPubSpecLock);

    if (!(await pubSpecYamlFile.exists())) {
      throw Exception(
          "'pubspec.yaml' file not found on location ${args.pathToPubSpec}");
    }

    if (!(await pubLockFile.exists())) {
      throw Exception(
          "'pubspec.lock' file not found on location ${args.pathToPubSpecLock}");
    }

    final pubSpecContents = await _getPubSpecContents(pubSpecYamlFile);
    final pubLockContents = await _getPubSpecLockContents(pubLockFile);

    return FileContents(
      pubSpecContents,
      pubLockContents,
    );
  }

  static Future<PubSpecYamlContents> _getPubSpecContents(
      final File file) async {
    List<PubSpecDependency> _getDependencies(
      final YamlDocument pubSpecDoc,
      final String pubSpecKey,
    ) {
      VersionConstraint _sanitizeDependencyVersion(final MapEntry it) =>
          it.value != null
              ? VersionConstraint.parse(it.value)
              : VersionConstraint.any;

      final YamlMap contents = (pubSpecDoc.contents as YamlMap)[pubSpecKey];
      return contents.entries
          .map(
            (it) => PubSpecDependency(
              name: it.key,
              version: !(it.value is YamlNode)
                  ? _sanitizeDependencyVersion(it)
                  : VersionConstraint.any,
            ),
          )
          .cast<PubSpecDependency>()
          .toList();
    }

    final pubSpecDoc = await _loadYamlFile(file);
    return PubSpecYamlContents(
      dependencies: _getDependencies(pubSpecDoc, depKey),
      devDependencies: _getDependencies(pubSpecDoc, devDepKey),
    );
  }

  static Future<PubSpecLockContents> _getPubSpecLockContents(
      final File file) async {
    List<ResolvedDependency> _getDependencies(final YamlDocument pubSpecDoc) {
      Version resolvedVersionFromDepMap(final YamlMap depNode) =>
          Version.parse(depNode[resolvedVersionKey]);

      final YamlMap contents =
          (pubSpecDoc.contents as YamlMap)[resolvedPackagesKey];
      return contents.entries
          .map(
            (it) => ResolvedDependency(
              name: it.key,
              version: resolvedVersionFromDepMap(it.value as YamlMap),
            ),
          )
          .toList();
    }

    final pubLockDoc = await _loadYamlFile(file);
    return PubSpecLockContents(_getDependencies(pubLockDoc));
  }

  static Future<YamlDocument> _loadYamlFile(final File file) async =>
      loadYamlDocument(await file.readAsString());
}
