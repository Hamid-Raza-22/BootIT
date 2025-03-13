// import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Models/shop_visit_model.dart';
import '../Services/ApiServices/api_service.dart';
import '../Services/ApiServices/serial_number_genterator.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';

class ShopVisitRepository extends GetxService{
  DBHelper dbHelper = DBHelper();
  Future<List<ShopVisitModel>> getShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(shopVisitMasterTableName, columns: [
      'shop_visit_master_id',
      'brand',
      'shop_visit_date',
      'shop_visit_time',
      'shop_name',
      'shop_address',
      'owner_name',
      'booker_name',
      'walk_through',
      'planogram',
      'signage',
      'product_reviewed',
      'feedback',
      'user_id',
      'posted'
,      'body'
    ]);
    List<ShopVisitModel> shopvisit = [];
    for (int i = 0; i < maps.length; i++) {
      shopvisit.add(ShopVisitModel.fromMap(maps[i]));
    }

      debugPrint('Raw data from Shop Visit Table database:');

    for (var map in maps) {

        debugPrint("$map");

    }
    return shopvisit;
  }
  Future<void> fetchAndSaveShopVisit() async {
    debugPrint('${Config.getApiUrlShopVisit}$user_id');
    List<dynamic> data = await ApiService.getData('${Config.getApiUrlShopVisit}$user_id');
    var dbClient = await dbHelper.db;

    // Save data to database
    for (var item in data) {
      item['posted'] = 1; // Set posted to 1
      ShopVisitModel model = ShopVisitModel.fromMap(item);
      await dbClient.insert(shopVisitMasterTableName, model.toMap());
    }
  }

  Future<List<ShopVisitModel>> getUnPostedShopVisit() async {
    var dbClient = await dbHelper.db;
    List<Map> maps = await dbClient.query(
      shopVisitMasterTableName,
      where: 'posted = ?',
      whereArgs: [0],  // Fetch machines that have not been posted
    );

    List<ShopVisitModel> attendanceIn = maps.map((map) => ShopVisitModel.fromMap(map)).toList();
    return attendanceIn;
  }

  Future<void> postDataFromDatabaseToAPI() async {
    try {
      var unPostedShops = await getUnPostedShopVisit();

      if (await isNetworkAvailable()) {
        for (var shop in unPostedShops) {
          try {
            await postShopToAPI(shop, shop.body!);
            shop.posted = 1;
            await update(shop);

              debugPrint('Shop with id ${shop.shop_visit_master_id} posted and updated in local database.');

          } catch (e) {

              debugPrint('Failed to post shop with id ${shop.shop_visit_master_id}: $e');

          }
        }
      } else {

          debugPrint('Network not available. Unposted shops will remain local.');

      }
    } catch (e) {

        debugPrint('Error fetching unposted shops: $e');

    }
  }





  Future<void> postShopToAPI(ShopVisitModel shop, Uint8List imageBytes) async {
    try {
      await Config.fetchLatestConfig();

        debugPrint('Updated Shop Post API: ${Config.postApiUrlShopVisit}');

      var shopData = shop.toMap();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Config.postApiUrlShopVisit),
      );

      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Accept'] = 'application/json';

      request.fields.addAll(shopData.map((key, value) => MapEntry(key, value.toString())));

      if (imageBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'body',
            imageBytes,
            contentType: MediaType('body', 'jpeg'), // Adjust the content type based on your image type
            // filename: 'upload.jpg',
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Shop data posted successfully: ${shop.toMap()}');

        // Delete the shop visit data from the local database after successful post
        await delete(shop.shop_visit_master_id!);

          debugPrint('Shop with id ${shop.shop_visit_master_id} deleted from local database.');

      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('Server error: ${response.statusCode}, $responseBody');
      }
    } catch (e) {
      debugPrint('Error posting shop data: $e');
      throw Exception('Failed to post data: $e');
    }
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
        where: 'shop_visit_master_id = ?',
        whereArgs: [shopvisitModel.shop_visit_master_id]);
  }

  Future<int> delete(String id) async {
    var dbClient = await dbHelper.db;
    return await dbClient
        .delete(shopVisitMasterTableName, where: 'shop_visit_master_id = ?', whereArgs: [id]);
  }
  Future<void> serialNumberGeneratorApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orderDetailsGenerator = SerialNumberGenerator(
      apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/shopvisitserial/get/$user_id',
      maxColumnName: 'max(shop_visit_master_id)',
      serialType: shopVisitHighestSerial, // Unique identifier for shop visit serials
    );
    await orderDetailsGenerator.getAndIncrementSerialNumber();
    shopVisitHighestSerial = orderDetailsGenerator.serialType;
    await prefs.reload();
    await prefs.setInt("shopVisitHighestSerial", shopVisitHighestSerial!);

  }
}
