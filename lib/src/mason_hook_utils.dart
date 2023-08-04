import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';

/// Type definition for [Process.run].
typedef RunProcess = Future<ProcessResult> Function(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  bool runInShell,
});

class PubspecYamlNotFoundException extends MasonException {
  const PubspecYamlNotFoundException() : super('Cannot find pubspec.yaml.');
}

class MasonHookUtils {
  const MasonHookUtils(this._logger);

  final Logger _logger;

  /// Runs `flutter pub add` in the current working directory to add
  /// [dependencies] to the `pubspec.yaml` file.
  ///
  /// {@template add_dependencies_params}
  /// If `isDevDependency` is `true` (default to `false`), then the dependencies
  /// will be added as dev dependencies.
  ///
  /// If `ignoreExistingDependencies` is `true` (default), then
  /// dependencies that already exist in the `pubspec.yaml` file
  /// will be ignored.
  /// {@endtemplate}
  Future<void> flutterAddDependencies(
    List<String> dependencies, {
    bool isDevDependency = false,
    bool ignoreExistingDependencies = true,
  }) async {
    if (ignoreExistingDependencies) {
      dependencies.removeExistingDependencies(cwd);
    }

    final pubProgress = _logger.progress(
      'Adding ${dependencies.join(',')} dependencies',
    );

    try {
      await runProcess(
        'flutter',
        ['pub', 'add', if (isDevDependency) '--dev', ...dependencies],
        runInShell: true,
        workingDirectory: cwd.path,
      );
      pubProgress.complete('Added ${dependencies.length} dependencies');
    } catch (e) {
      pubProgress.fail('Failed to add dependencies: $e');
    }
  }

  /// Runs `flutter packages get` in the current working directory.
  Future<void> flutterPackagesGet() async {
    final pubProgress = _logger.progress('Running flutter packages get');

    try {
      await runProcess(
        'flutter',
        ['packages', 'get'],
        runInShell: true,
        workingDirectory: cwd.path,
      );
      pubProgress.complete('Completed flutter packages get');
    } catch (e) {
      pubProgress.fail('Failed to run flutter packages get: $e');
    }
  }

  /// Runs `dart pub add` in the current working directory to add
  /// [dependencies] to the `pubspec.yaml` file.
  ///
  /// {@macro add_dependencies_params}
  Future<void> dartPubAdd(
    List<String> dependencies, {
    bool isDevDependency = false,
    bool ignoreExistingDependencies = true,
  }) async {
    if (ignoreExistingDependencies) {
      dependencies.removeExistingDependencies(cwd);
    }

    final pubProgress = _logger.progress(
      'Adding ${dependencies.join(',')} dependencies',
    );

    try {
      await runProcess(
        'dart',
        ['pub', 'add', if (isDevDependency) '--dev', ...dependencies],
        runInShell: true,
        workingDirectory: cwd.path,
      );
      pubProgress.complete('Added ${dependencies.length} dependencies');
    } catch (e) {
      pubProgress.fail('Failed to add dependencies: $e');
    }
  }

  /// Runs `dart pub get` in the current working directory.
  Future<void> dartPubGet() async {
    final pubProgress = _logger.progress('Running dart pub get');

    try {
      await runProcess(
        'dart',
        ['pub', 'get'],
        runInShell: true,
        workingDirectory: cwd.path,
      );
      pubProgress.complete('Completed dart pub get');
    } catch (e) {
      pubProgress.fail('Failed to run dart pub get: $e');
    }
  }

  /// The method used to run a [Process].
  ///
  /// This is exposed for testing purposes.
  RunProcess get runProcess => Process.run;

  /// Return the current working directory.
  Directory get cwd => Directory.current;

  /// Finds nearest ancestor `pubspec.yaml` file
  /// relative to the [cwd].
  static File? _findNearestPubspec(Directory cwd) {
    Directory? prev;
    Directory dir = cwd;
    while (prev?.path != dir.path) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) return pubspec;
      prev = dir;
      dir = dir.parent;
    }
    return null;
  }
}

extension on List<String> {
  void removeExistingDependencies(Directory cwd) {
    final nearestPubspec = MasonHookUtils._findNearestPubspec(cwd);
    if (nearestPubspec == null) {
      throw const PubspecYamlNotFoundException();
    }

    final pubspec = Pubspec.parse(nearestPubspec.readAsStringSync());
    final existingDependencies = pubspec.dependencies;
    removeWhere(existingDependencies.containsKey);
  }
}
