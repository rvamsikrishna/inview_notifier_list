# Contributing to inview_notifier_list

Thanks for considering contributing! This package has been around since 2019 and is used by thousands of developers. Every contribution — bug reports, feature requests, documentation improvements, and code changes — helps make it better.

## Getting Started

### 1. Fork & Clone

```bash
git clone https://github.com/<your-username>/inview_notifier_list.git
cd inview_notifier_list
```

### 2. Install Dependencies

```bash
flutter pub get
cd example && flutter pub get && cd ..
```

### 3. Verify Your Setup

Before making any changes, make sure everything is green:

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
flutter test
```

## Making Changes

### Bug Fixes

If you've found a bug, feel free to open a PR directly with a fix. Please include:

- A clear description of the bug
- A test that fails without the fix and passes with it

### Features & Non-Trivial Changes

For new features or significant changes, **open an issue first** to discuss the approach. This avoids wasted effort if the change doesn't align with the package's scope.

This package intentionally has a small API surface. Not every feature request will be accepted — and that's OK.

### What We Look For in PRs

- **Tests**: Every PR must include tests for the changed behavior. We maintain 90%+ code coverage and every test should catch a real bug, not just pad a number.
- **No unnecessary changes**: Don't refactor surrounding code, add comments to code you didn't change, or "improve" unrelated files. Keep the diff focused.
- **Backward compatibility**: If your change breaks the public API, it needs a strong justification and a major version bump.

## Quality Checks

Run all of these before pushing. CI will catch them, but it's faster to catch locally.

### Format

```bash
dart format .
```

### Analyze

```bash
dart analyze --fatal-infos
```

Zero warnings, zero infos. No exceptions.

### Test

```bash
flutter test
```

All tests must pass. If you're adding new behavior, add tests for it.

### Coverage

```bash
flutter test --coverage
```

**CI enforces a minimum of 90% code coverage.** PRs that drop coverage below this threshold will fail the CI check and cannot be merged. That said, don't write tests just to increase a number — write tests that catch real bugs.

## Code Style

- Follow the [Dart style guide](https://dart.dev/effective-dart/style).
- The project uses `flutter_lints` — the analyzer will catch most style issues.
- Use `super.key` and super parameters (Dart 3 style).
- Prefer `const` constructors where possible.
- No unnecessary `Container` wrappers — use `SizedBox`, `ColoredBox`, etc.

## Commit Messages

Use clear, descriptive commit messages:

```
fix: resolve stale context crash when widget is removed during scroll
feat: add support for SliverAppBar in CustomScrollView
test: add onListEndReached callback tests
chore: update dependencies
```

- `fix:` for bug fixes
- `feat:` for new features
- `test:` for test-only changes
- `chore:` for maintenance (deps, CI, docs)
- `docs:` for documentation changes

## Changelog

If your change is user-facing (bug fix, feature, breaking change), add an entry to `CHANGELOG.md` under an `## [Unreleased]` section at the top. The maintainer will assign the version number on release.

## Pull Request Process

1. Create a branch from `master` with a descriptive name
2. Make your changes with tests
3. Run format, analyze, and test locally
4. Push and open a PR against `master`
5. Fill in the PR description — what changed and why
6. Wait for CI to pass and a review from the maintainer

## Example App

If your change affects the widget API, update the example app to demonstrate it. The example app should always build and run on the latest stable Flutter.

```bash
cd example
flutter run
```

## Questions?

Open an issue with the `question` label. No question is too small.
