import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:map_flutter/realm_neighborhood.dart';
/// result : [{"_id":"American"},{"_id":"Chinese"},{"_id":"Café/Coffee/Tea"},{"_id":"Pizza"},{"_id":"Italian"},{"_id":"Other"},{"_id":"Latin (Cuban, Dominican, Puerto Rican, South & Central American)"},{"_id":"Japanese"},{"_id":"Mexican"},{"_id":"Bakery"},{"_id":"Caribbean"},{"_id":"Spanish"},{"_id":"Donuts"},{"_id":"Pizza/Italian"},{"_id":"Sandwiches"},{"_id":"Hamburgers"},{"_id":"Chicken"},{"_id":"Ice Cream, Gelato, Yogurt, Ices"},{"_id":"French"},{"_id":"Delicatessen"},{"_id":"Jewish/Kosher"},{"_id":"Indian"},{"_id":"Asian"},{"_id":"Thai"},{"_id":"Juice, Smoothies, Fruit Salads"},{"_id":"Korean"},{"_id":"Sandwiches/Salads/Mixed Buffet"},{"_id":"Mediterranean"},{"_id":"Irish"},{"_id":"Middle Eastern"},{"_id":"Bagels/Pretzels"},{"_id":"Seafood"},{"_id":"Tex-Mex"},{"_id":"Greek"},{"_id":"Vegetarian"},{"_id":"Russian"},{"_id":"Steak"},{"_id":"Bottled beverages, including water, sodas, juices, etc."},{"_id":"Turkish"},{"_id":"Peruvian"},{"_id":"African"},{"_id":"Vietnamese/Cambodian/Malaysia"},{"_id":"Eastern European"},{"_id":"Chinese/Japanese"},{"_id":"Continental"},{"_id":"Barbecue"},{"_id":"Soups & Sandwiches"},{"_id":"Salads"},{"_id":"Soul Food"},{"_id":"Armenian"},{"_id":"Bangladeshi"},{"_id":"Hotdogs"},{"_id":"Pakistani"},{"_id":"German"},{"_id":"Tapas"},{"_id":"Filipino"},{"_id":"Brazilian"},{"_id":"Polish"},{"_id":"Creole"},{"_id":"Not Listed/Not Applicable"},{"_id":"Ethiopian"},{"_id":"Hotdogs/Pretzels"},{"_id":"Pancakes/Waffles"},{"_id":"English"},{"_id":"Chinese/Cuban"},{"_id":"Australian"},{"_id":"Moroccan"},{"_id":"Afghan"},{"_id":"Egyptian"}]
part 'cuisine.g.dart';



// Utility function that manages the communication between the express/node server
// and the flutter application
Future<Set<String?>?> getRestaurantTypes(String limit) async {
  await dotenv.load(fileName: '.env');
  String? host = dotenv.env['HOST'];
  String? port = dotenv.env['PORT'];
  log.info("getRestaurantTypes $limit");
  String url = "http://${host}:$port/byCuisine?limit=" + limit;

  final uri = Uri.parse(url);
  log.info("Url is " + uri.toString());
  try {
    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 10))
        .whenComplete(() => log.info("Done " ));
    if (response.statusCode == 200) {
      log.info("Success");
      Cuisine? cuisine =  Cuisine.fromJson(jsonDecode(response.body));
      List<Result>? list = cuisine.result;
      List<String> restaurantTypes  = [];
      if( list != null ) {
       return   list.where((element) => element._id is String).map((e) => e._id).toSet();
      }
    } else {
      log.shout("Failed: " + response.statusCode.toString());
    }
  } catch (e) {
    log.severe("Exception " + e.toString(), e);
  }
}


@JsonSerializable()
class Cuisine {
  Cuisine({
      List<Result>? result,}){
    _result = result;
}

  Cuisine.fromJson(dynamic json) {
    if (json['result'] != null) {
      _result = [];
      json['result'].forEach((v) {
        _result?.add(Result.fromJson(v));
      });
    }
  }
  List<Result>? _result;

  List<Result>? get result => _result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_result != null) {
      map['result'] = _result?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// _id : "American"
@JsonSerializable()
class Result {
  Result({
      String? id,}){
    _id = id;
}

  Result.fromJson(dynamic json) {
    _id = json['_id'];
  }
  String? _id;

  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    return map;
  }

}