import 'package:dep_check/src/comparator.dart' as c;
import 'package:dep_check/src/models.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  CompareInput _mapToCompareInput(List<_TestCase> testCases) {
    final List<PubSpecDependency> allDependencies = [];
    final List<ResolvedDependency> lockFileDependencies = [];
    final List<ResolvedDependency> pubDevDependencies = [];

    testCases.forEach((testCase) {
      allDependencies.add(PubSpecDependency(name: testCase.name, version: VersionConstraint.parse(testCase.pubSpec)));
      lockFileDependencies.add(ResolvedDependency(name: testCase.name, version: Version.parse(testCase.lockFile)));
      pubDevDependencies.add(ResolvedDependency(name: testCase.name, version: Version.parse(testCase.pubDev)));
    });

    return CompareInput(
      allDependencies,
      lockFileDependencies,
      pubDevDependencies,
    );
  }

  group("up to date dependencies", () {
    final compareInput = _mapToCompareInput([
      _TestCase("a", pubSpec: "^1.0.0", lockFile: "1.0.0", pubDev: "1.0.0"),
      _TestCase("b", pubSpec: "1.0.0", lockFile: "1.0.0", pubDev: "1.0.0"),
    ]);

    test("should all be parsed as up to date", () {
      final output = c.Comparator.compareVersions(compareInput);
      expect(output.upToDateDependencies.length, 2);
      expect(output.pubUpgradeableDependencies.length, 0);
      expect(output.manualUpdatableDependencies.length, 0);
    });
  });

  group("pub upgradable dependencies", () {
    final compareInput = _mapToCompareInput([
      _TestCase("a", pubSpec: "^1.0.0", lockFile: "1.0.0", pubDev: "1.0.1"),
      _TestCase("b", pubSpec: "^1.1.0", lockFile: "1.1.0", pubDev: "1.9.9"),
    ]);

    test("should all be parsed as pub upgradable dependencies", () {
      final output = c.Comparator.compareVersions(compareInput);
      expect(output.upToDateDependencies.length, 0);
      expect(output.pubUpgradeableDependencies.length, 2);
      expect(output.manualUpdatableDependencies.length, 0);
    });
  });

  group("manually upgradable dependencies", () {
    final compareInput = _mapToCompareInput([
      _TestCase("a", pubSpec: "^1.0.0", lockFile: "1.0.0", pubDev: "2.0.0"),
      _TestCase("b", pubSpec: "^1.1.0", lockFile: "1.1.0", pubDev: "2.0.0"),
      _TestCase("c", pubSpec: "^0.9.0", lockFile: "0.9.0", pubDev: "1.0.0"),
    ]);

    test("should all be parsed as manually upgradable dependencies", () {
      final output = c.Comparator.compareVersions(compareInput);
      expect(output.upToDateDependencies.length, 0);
      expect(output.pubUpgradeableDependencies.length, 0);
      expect(output.manualUpdatableDependencies.length, 3);
    });
  });
}

class _TestCase {
  final String name;
  final String pubSpec;
  final String lockFile;
  final String pubDev;

  _TestCase(this.name, {this.pubSpec, this.lockFile, this.pubDev})
      : assert(name != null),
        assert(pubSpec != null),
        assert(lockFile != null),
        assert(pubDev != null);
}
