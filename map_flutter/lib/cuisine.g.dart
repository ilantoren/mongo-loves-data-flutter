// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuisine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cuisine _$CuisineFromJson(Map<String, dynamic> json) => Cuisine(
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => Result.fromJson(e))
          .toList(),
    );

Map<String, dynamic> _$CuisineToJson(Cuisine instance) => <String, dynamic>{
      'result': instance.result,
    };

Result _$ResultFromJson(Map<String, dynamic> json) => Result(
      id: json['id'] as String?,
    );

Map<String, dynamic> _$ResultToJson(Result instance) => <String, dynamic>{
      'id': instance.id,
    };
