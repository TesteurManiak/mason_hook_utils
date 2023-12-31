<h1 align="center">🧱 Mason Hook Utils</h1>

<p align="center">
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
  <a href="https://github.com/felangel/mason"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge" alt="Powered by Mason"></a>
</p>

A collection of utilities to use inside [mason][mason] hooks when creating bricks.

## Usage

* Add the package to your `hooks/pubspec.yaml` file:

```yaml
name: my_hooks

dependencies:
    mason: any
    mason_hook_utils: any
```

* Use it in your hooks:

```dart
import 'package:mason/mason.dart';
import 'package:mason_hook_utils/mason_hook_utils.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final hookUtils = MasonHookUtils(logger);

  await hookUtils.flutterAddDependencies(/* ... */);

  await hookUtils.flutterPackagesGet();
}
```

## Utilities

### `flutterAddDependencies`

Runs `flutter pub add` in the current working directory to add dependencies to the `pubspec.yaml` file. By default, already existing dependencies will be ignored, this can be changed by setting the `ignoreExistingDependencies` parameter to `false`.

You can also set the paramater isDevDependency to `true` (default to `false`) to add the dependency as a dev dependency.

## `flutterPackagesGet`

Runs `flutter pub get` in the current working directory.

## `dartPubAdd`

Runs `dart pub add` in the current working directory to add dependencies to the `pubspec.yaml` file. By default, already existing dependencies will be ignored, this can be changed by setting the `ignoreExistingDependencies` parameter to `false`.

You can also set the paramater isDevDependency to `true` (default to `false`) to add the dependency as a dev dependency.

## `dartPubGet`

Runs `dart pub get` in the current working directory.


[mason]: https://pub.dev/packages/mason