// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_neighborhood.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Realm_neighborhood _$Realm_neighborhoodFromJson(Map<String, dynamic> json) =>
    Realm_neighborhood(
      coord: (json['coord'] as List<dynamic>?)
          ?.map((e) => Coord.fromJson(e))
          .toList(),
      avgLong: (json['avgLong'] as num?)?.toDouble(),
      avgLat: (json['avgLat'] as num?)?.toDouble(),
      name: json['name'] as String?,
      restaurants: (json['restaurants'] as List<dynamic>?)
          ?.map((e) => Restaurants.fromJson(e))
          .toList(),
      long: (json['long'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      lat: (json['lat'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$Realm_neighborhoodToJson(Realm_neighborhood instance) =>
    <String, dynamic>{
      'coord': instance.coord,
      'avgLong': instance.avgLong,
      'avgLat': instance.avgLat,
      'name': instance.name,
      'restaurants': instance.restaurants,
      'long': instance.long,
      'lat': instance.lat,
    };

Restaurants _$RestaurantsFromJson(Map<String, dynamic> json) => Restaurants(
      id: json['id'] as String?,
      address:
          json['address'] == null ? null : Address.fromJson(json['address']),
      borough: json['borough'] as String?,
      cuisine: json['cuisine'] as String?,
      grades: (json['grades'] as List<dynamic>?)
          ?.map((e) => Grades.fromJson(e))
          .toList(),
      name: json['name'] as String?,
      restaurantId: json['restaurantId'] as String?,
      geometry:
          json['geometry'] == null ? null : Geometry.fromJson(json['geometry']),
    );

Map<String, dynamic> _$RestaurantsToJson(Restaurants instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'borough': instance.borough,
      'cuisine': instance.cuisine,
      'grades': instance.grades,
      'name': instance.name,
      'restaurantId': instance.restaurantId,
      'geometry': instance.geometry,
    };

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

Grades _$GradesFromJson(Map<String, dynamic> json) => Grades(
      date: json['date'] as String?,
      grade: json['grade'] as String?,
      score: json['score'] as int?,
    );

Map<String, dynamic> _$GradesToJson(Grades instance) => <String, dynamic>{
      'date': instance.date,
      'grade': instance.grade,
      'score': instance.score,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      building: json['building'] as String?,
      coord: (json['coord'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      street: json['street'] as String?,
      zipcode: json['zipcode'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'building': instance.building,
      'coord': instance.coord,
      'street': instance.street,
      'zipcode': instance.zipcode,
    };

Coord _$CoordFromJson(Map<String, dynamic> json) => Coord(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CoordToJson(Coord instance) => <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };
