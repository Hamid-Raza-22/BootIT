import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/shop_visit_model.dart';

class ShopVisitRepository extends GetxService{
  DBHelper dbHelper = DBHelper();
  Future<List<ShopVisitModel>> getShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitMasterTableName, columns: [
      'shopVisitMasterId',
      'brand',
      'shop_name',
      'shop_address',
      'owner_name',
      'booker_name',
      'walkthrough',
      'planogram',
      'signage',
      'productReviewed',
      'feedback',
      'body'
    ]);
    List<ShopVisitModel> shopvisit = [];
    for (int i = 0; i < maps.length; i++) {
      shopvisit.add(ShopVisitModel.fromMap(maps[i]));
    }
    if (kDebugMode) {
      print('Raw data from Shop Visit Table database:');
    }
    for (var map in maps) {
      if (kDebugMode) {
        print(map);
      }
    }
    return shopvisit;
  }

  Future<int> add(ShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.insert(
        shopVisitMasterTableName, shopvisitModel.toMap());
  }

  Future<int> update(ShopVisitModel shopvisitModel) async {
    var dbClient = await dbHelper.db;
    return await dbClient.update(
        shopVisitMasterTableName, shopvisitModel.toMap(),
        where: 'shopVisitMasterId = ?', whereArgs: [shopvisitModel.shopVisitMasterId]);
  }

  Future<int> delete(int id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(shopVisitMasterTableName, where: 'shopVisitMasterId = ?', whereArgs: [id]);
  }
}
