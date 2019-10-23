import 'dart:convert';
import 'dart:io';

import 'package:dep_check/src/models.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

class PubService {
  PubService._();

  static const baseUrl = "https://pub.dev/api/packages";

  static Future<List<ResolvedDependency>> lastVersions(
      List<PubSpecDependency> dependencies) {
    Future<Version> _latestVersionForDependency(
        final PubSpecDependency dep) async {
      final response = await http.get("${PubService.baseUrl}/${dep.name}");
      Version version;
      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        version = Version.parse(decodedJson["latest"]["version"]);
      } else {
        stderr.writeln("🤷‍♂️ Could not find latest version for ${dep.name}");
      }
      return version ?? Version.none;
    }

    return Future.wait(dependencies.map((dep) async {
      final latestVersion = await _latestVersionForDependency(dep);
      return ResolvedDependency(
        name: dep.name,
        version: latestVersion,
      );
    }).toList());
  }
}
