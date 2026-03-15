// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$githubServiceHash() => r'fcdccdca340f0aa1eda3675ab4dcbbce696bbe1e';

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
String _$githubReposHash() => r'de6c58c0d695aacc8f055181c8d6c5dfecba0208';

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
