import 'package:freezed_annotation/freezed_annotation.dart';

part 'language.freezed.dart';
part 'language.g.dart';

@freezed
class Language with _$Language {
  const factory Language({
    int? id,
    @JsonKey(name: 'profile_id') String? profileId,
    required String name,
    String? proficiency,
    @JsonKey(name: 'sort_order') int? orderIndex,
  }) = _Language;

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);
}
