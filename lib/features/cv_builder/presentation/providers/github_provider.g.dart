// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$githubServiceHash() => r'cc9bc31f6ad7ea99109e9783a83dda84026931a4';

/// See also [githubService].
@ProviderFor(githubService)
final githubServiceProvider = AutoDisposeProvider<GithubService>.internal(
  githubService,
  name: r'githubServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$githubServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GithubServiceRef = AutoDisposeProviderRef<GithubService>;
String _$githubReposHash() => r'ba0af78c7427ea4aa436f857182485f1e3861ce6';

/// See also [githubRepos].
@ProviderFor(githubRepos)
final githubReposProvider =
    AutoDisposeFutureProvider<List<GithubRepo>>.internal(
      githubRepos,
      name: r'githubReposProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$githubReposHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GithubReposRef = AutoDisposeFutureProviderRef<List<GithubRepo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
