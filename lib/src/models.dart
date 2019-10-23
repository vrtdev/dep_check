import 'package:pub_semver/pub_semver.dart';

class Input {
  final String pathToPubSpec;
  final String pathToPubSpecLock;

  Input(
    this.pathToPubSpec,
    this.pathToPubSpecLock,
  );

  @override
  String toString() => 'CLIArguments{$pathToPubSpec, $pathToPubSpecLock}';
}

class PubSpecDependency {
  final VersionConstraint version;
  final String name;

  PubSpecDependency({this.name, this.version})
      : assert(version != null),
        assert(name != null);

  @override
  String toString() => 'Dependency{$name, $version}';
}

class ResolvedDependency {
  final Version version;
  final String name;

  ResolvedDependency({this.name, this.version})
      : assert(version != null),
        assert(name != null);
}

class ProcessedDependency extends Comparable<ProcessedDependency> {
  final String name;
  final String currentVersion;
  final String latestVersion;

  ProcessedDependency._(
    this.name,
    this.currentVersion,
    this.latestVersion,
  );

  ProcessedDependency.fromPubSpecDependency(
      final PubSpecDependency dep, final Version latestVersion)
      : this._(
          dep.name,
          dep.version.toString(),
          VersionConstraint.compatibleWith(latestVersion).toString(),
        );

  @override
  int compareTo(final ProcessedDependency other) => name.compareTo(other.name);
}

class PubSpecYamlContents {
  final List<PubSpecDependency> dependencies;
  final List<PubSpecDependency> devDependencies;

  PubSpecYamlContents({
    this.dependencies,
    this.devDependencies,
  })  : assert(dependencies != null),
        assert(devDependencies != null);

  List<PubSpecDependency> get allDependencies =>
      (dependencies + devDependencies).toSet().toList();
}

class PubSpecLockContents {
  final List<ResolvedDependency> resolvedDependencies;

  PubSpecLockContents(this.resolvedDependencies);
}

class FileContents {
  final PubSpecYamlContents yamlContents;
  final PubSpecLockContents lockContents;

  FileContents(this.yamlContents, this.lockContents);
}

class CompareInput {
  final List<PubSpecDependency> allDependencies;
  final List<ResolvedDependency> lockFileDependencies;
  final List<ResolvedDependency> pubDevDependencies;

  CompareInput(
    this.allDependencies,
    this.lockFileDependencies,
    this.pubDevDependencies,
  );
}

class Output {
  final List<ProcessedDependency> upToDateDependencies;
  final List<ProcessedDependency> pubUpgradeableDependencies;
  final List<ProcessedDependency> manualUpdatableDependencies;

  Output(
    this.upToDateDependencies,
    this.pubUpgradeableDependencies,
    this.manualUpdatableDependencies,
  );
}
