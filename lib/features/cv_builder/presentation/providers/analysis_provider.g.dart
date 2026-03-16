// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$autonomousAnalysisServiceHash() =>
    r'675c4ebe64a5058d9fb8497e4cd02753c3611d70';

/// See also [autonomousAnalysisService].
@ProviderFor(autonomousAnalysisService)
final autonomousAnalysisServiceProvider =
    AutoDisposeProvider<AutonomousAnalysisService>.internal(
      autonomousAnalysisService,
      name: r'autonomousAnalysisServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$autonomousAnalysisServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AutonomousAnalysisServiceRef =
    AutoDisposeProviderRef<AutonomousAnalysisService>;
String _$analysisNotifierHash() => r'7dccf9bacaa43e8be5a8ba1c287e5f346991371e';

/// See also [AnalysisNotifier].
@ProviderFor(AnalysisNotifier)
final analysisNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      AnalysisNotifier,
      List<AnalyzedProject>
    >.internal(
      AnalysisNotifier.new,
      name: r'analysisNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analysisNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnalysisNotifier = AutoDisposeAsyncNotifier<List<AnalyzedProject>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
