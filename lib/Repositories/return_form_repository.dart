import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/return_form_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class ReturnFormRepository {
  DBHelper dbHelper = DBHelper();
  Future<List<ReturnFormModel>> getReturnForm() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(returnFormMasterTableName,
        columns: ['return_master_id', 'select_shop',
          'return_master_date','return_master_time', 'posted']);
    List<ReturnFormModel> returnform = [];
    for (int i = 0; i < maps.length; i++) {
      returnform.add(ReturnFormModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Return form Raw data from database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return returnform;
  }
  Future<void> fetchAndSaveReturnForm() async {
    print('${Config.getApiUrlReturnForm}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlReturnForm}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ReturnFormModel model = ReturnFormModel.fromMap(item);
      await dbClient.insert(returnFormMasterTableName, model.toMap());
    }
  }

  Future<List<ReturnFormModel>> getUnPostedReturnForm() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      returnFormMasterTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<ReturnFormModel> attendanceIn = maps.map((map) => ReturnFormModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedReturnForm();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop);
            shop.posted = 1;
            await update(shop);
            if (kDebugMode) {
              print('Shop with id ${shop.return_master_id} posted and updated in local database.');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Failed to post shop with id ${shop.return_master_id}: $e');
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

  Future<void> postShopToAPI(ReturnFormModel shop) async {
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
  Future<int> add(ReturnFormModel returnformModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        returnFormMasterTableName, returnformModel.toMap());
  }

  Future<int> update(ReturnFormModel returnformModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        returnFormMasterTableName, returnformModel.toMap(),
        where: 'id = ?', whereArgs: [returnformModel.return_master_id]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(returnFormMasterTableName, where: 'id = ?', whereArgs: [id]);
  }
}
