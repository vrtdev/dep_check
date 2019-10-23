import 'package:dep_check/src/models.dart';
import 'package:pub_semver/pub_semver.dart';

class Comparator {
  Comparator._();

  static Output compareVersions(final CompareInput input) {
    final bool Function(PubSpecDependency, ResolvedDependency)
        resolvedPredicate = (pubDep, otherDep) => pubDep.name == otherDep.name;
    bool isNewVersionAvailableOnPub(Version pubDevDep, Version lockFileDep) =>
        pubDevDep > lockFileDep;
    bool canBeUpgradedWithPubUpgrade(final VersionConstraint pubSpecConstraint,
            final Version pubDevDep) =>
        pubSpecConstraint.allows(pubDevDep);

    final List<ProcessedDependency> upToDateDependencies = [];
    final List<ProcessedDependency> pubUpgradeableDependencies = [];
    final List<ProcessedDependency> manualUpdatableDependencies = [];

    input.allDependencies.forEach((dependency) {
      final pubSpecConstraint = dependency.version;
      final lockFileDep = input.lockFileDependencies
          .firstWhere((it) => resolvedPredicate(dependency, it))
          .version;
      final pubDevDep = input.pubDevDependencies
          .firstWhere((it) => resolvedPredicate(dependency, it))
          .version;

      if (isNewVersionAvailableOnPub(pubDevDep, lockFileDep)) {
        canBeUpgradedWithPubUpgrade(pubSpecConstraint, pubDevDep)
            ? pubUpgradeableDependencies.add(
                ProcessedDependency.fromPubSpecDependency(
                  dependency,
                  pubDevDep,
                ),
              )
            : manualUpdatableDependencies.add(
                ProcessedDependency.fromPubSpecDependency(
                  dependency,
                  pubDevDep,
                ),
              );
      } else {
        upToDateDependencies.add(
            ProcessedDependency.fromPubSpecDependency(dependency, pubDevDep));
      }
    });

    return Output(
      upToDateDependencies,
      pubUpgradeableDependencies,
      manualUpdatableDependencies,
    );
  }
}
