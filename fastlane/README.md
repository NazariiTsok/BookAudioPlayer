fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios release

```sh
[bundle exec] fastlane ios release
```

Deploy a new version to the App Store

Options: scheme, target, install_pods

### ios dev

```sh
[bundle exec] fastlane ios dev
```

Builds and uploads the app using the dev environment.

Available options: skip_build_upload

### ios staging

```sh
[bundle exec] fastlane ios staging
```

Builds and uploads the app using the staging environment.

Available options: skip_build_upload

### ios code_signing

```sh
[bundle exec] fastlane ios code_signing
```

Updates code signing on the current machine

### ios release_beta

```sh
[bundle exec] fastlane ios release_beta
```

Description of what the lane does

### ios match_certificates

```sh
[bundle exec] fastlane ios match_certificates
```

Code Sign and Provising Profiles Sync

### ios run_unit_tests

```sh
[bundle exec] fastlane ios run_unit_tests
```

Run all the tests

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the app

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
