import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


String globalselectedbrand="";
String userBrand="";
double totalDistance=0.0;
String user_id= "";
String userName="";
String userCity="";
String userDesignation="";
String? shop_visit_master_id = "";
String? returnMasterId = "";
String? order_master_id = "";

String? recoverySavedMonthCounter;
int? recoveryHighestSerial;
int? shopVisitHighestSerial;
int? shopVisitDetailsHighestSerial;
int? orderMasterHighestSerial;
int? orderDetailsHighestSerial;
int? returnDetailsHighestSerial;
int? returnMasterHighestSerial;
int? attendanceInHighestSerial;
int? attendanceOutHighestSerial;
int? locationHighestSerial;
int? shopHighestSerial;

// bool isClockedIn = false;
// late Timer timer;
// int secondsPassed=0;

const addShopTableName = "addShop";
const shopVisitMasterTableName = "shopMasterVisit";
const shopVisitDetailsTableName = "shopVisitDetails";
const orderMasterTableName = "orderMaster";
const orderMasterStatusTableName = "orderMasterStatus";
const orderDetailsTableName = "orderDetails";
const returnFormMasterTableName = "reConfirmOrder";
const returnFormDetailsTableName = "returnFormDetails";
const recoveryFormTableName = "recoveryForm";
const attendanceTableName = "attendance";
const attendanceOutTableName = "attendanceOut";
const locationTableName = "location";
const productsTableName = "products";
const tableNameLogin ='login';

// Future<bool> isNetworkAvailable() async {
//   var connectivityResult = await (Connectivity().checkConnectivity());
//   return connectivityResult != ConnectivityResult.none;
// }

// Function to check internet connection
// Future<bool> isNetworkAvailable() async {
//   var connectivityResult = await (Connectivity().checkConnectivity());
//
//   if (connectivityResult == ConnectivityResult.none) {
//     return false; // No internet connection
//   } else {
//     try {
//       // Test a network request to verify if internet access is available
//       // final result = await InternetAddress.lookup('google.com');
//       final result = await InternetAddress.lookup('https://cloud.metaxperts.net:8443/erp/test1/ordermasterget/get/B02');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return true; // Internet connection is working
//       }
//     } catch (e) {
//       return false; // No internet connection
//     }
//   }
//   return false;
// }



Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.none) {
    return false; // No internet connection
  } else {
    try {
      // Replace with your server URL
      final url = Uri.parse('https://cloud.metaxperts.net:8443/erp/test1/ordermasterget/get/B02');

      // Make an HTTP GET request to your server
      final response = await http.get(url).timeout(Duration(seconds: 5));

      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        return true; // Server is reachable
      } else {
        return false; // Server returned an error
      }
    } on SocketException catch (_) {
      return false; // No internet connection or server unreachable
    } on TimeoutException catch (_) {
      return false; // Request timed out
    } catch (e) {
      return false; // Other errors
    }
  }
}
// Future<void> checkAndSetInitializationDateTime() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   // Check if 'lastInitializationDateTime' is already stored
//   String? lastInitDateTime = prefs.getString('lastInitializationDateTime');
//
//   if (lastInitDateTime == null) {
//     // If not, set the current date and time
//     DateTime now = DateTime.now();
//     String formattedDateTime = DateFormat('dd-MMM-yyyy-HH:mm:ss').format(now);
//     await prefs.setString('lastInitializationDateTime', formattedDateTime);
//
//       debugPrint('lastInitializationDateTime was not set, initializing to: $formattedDateTime');
//
//   } else {
//
//     debugPrint('lastInitializationDateTime is already set to: $lastInitDateTime');
//
//   }

