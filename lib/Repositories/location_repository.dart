import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/location_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class LocationRepository {
  DBHelper dbHelper = DBHelper();

  Future<List<LocationModel>> getLocation() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(locationTableName, columns: [
      'location_id',
      'location_date',
      'location_time',
      'file_name',
      'user_id',
      'booker_name',
      'total_distance',
      'body',
      'posted'
    ]);
    List<LocationModel> location = [];
    for (int i = 0; i < maps.length; i++) {
      location.add(LocationModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from Location database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return location;
  }

  Future<void> fetchAndSaveLocation() async {
    print('${Config.getApiUrlLocation}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlLocation}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      LocationModel model = LocationModel.fromMap(item);
      await dbClient.insert(locationTableName, model.toMap());
    }
  }

  Future<List<LocationModel>> getUnPostedLocation() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      locationTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<LocationModel> attendanceIn = maps.map((map) => LocationModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedLocation();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.location_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.location_id}: $e');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print('Network not available. Unposted shops will remain local.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching unposted shops: $e');
      }
    }
  }

  Future<void> postShopToAPI(LocationModel shop) async {
    try {
      await Config.fetchLatestConfig();
      if (kDebugMode) {
        print('Updated Shop Post API: ${Config.postApiUrlShops}');
      }
      var shopData = shop.toMap();
      final response = await http.post(
        Uri.parse(Config.postApiUrlShops),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(shopData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Shop data posted successfully: $shopData');
      } else {
        throw Exception('Server error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
  }
  Future<int> add(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(locationTableName, locationModel.toMap());
  }

  Future<int> update(LocationModel locationModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(locationTableName, locationModel.toMap(),
        where: 'location_id = ?', whereArgs: [locationModel.location_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(locationTableName, where: 'location_id = ?', whereArgs: [id]);
  }
}
