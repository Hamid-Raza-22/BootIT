import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Databases/util.dart';
import '../Models/attendanceOut_model.dart';
import '../Repositories/attendance_out_repository.dart';
import '../Services/FirebaseServices/firebase_remote_config.dart';
import 'location_view_model.dart';
class AttendanceOutViewModel extends GetxController{

  // var clockedIn = false.obs;
  // var clockedOut = false.obs;
  //
  // void setClockIn(bool value) {
  //   clockedIn.value = value;
  //   clockedOut.value = !value;
  // }
  //
  // void setClockOut(bool value) {
  //   clockedOut.value = value;
  //   clockedIn.value = !value;
  // }
  var allAttendanceOut = <AttendanceOutModel>[].obs;
  AttendanceOutRepository attendanceOutRepository = AttendanceOutRepository();
  LocationViewModel locationViewModel = Get.put(LocationViewModel());

  int attendanceOutSerialCounter = 1;
  String attendanceOutCurrentMonth = DateFormat('MMM').format(DateTime.now());
  String currentuser_id = '';
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    fetchAllAttendanceOut();
  }

  Future<void> _loadCounter() async {
    String currentMonth = DateFormat('MMM').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    attendanceOutSerialCounter = (prefs.getInt('attendanceOutSerialCounter') ?? attendanceOutHighestSerial?? 1);
    attendanceOutCurrentMonth =
        prefs.getString('attendanceOutCurrentMonth') ?? currentMonth;
    currentuser_id = prefs.getString('currentuser_id') ?? '';

    if (attendanceOutCurrentMonth != currentMonth) {
      attendanceOutSerialCounter = 1;
      attendanceOutCurrentMonth = currentMonth;
    }

      debugPrint('SR: $attendanceOutSerialCounter');

  }

  Future<void> _saveCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('attendanceOutSerialCounter', attendanceOutSerialCounter);
    await prefs.setString('attendanceOutCurrentMonth', attendanceOutCurrentMonth);
    await prefs.setString('currentuser_id', currentuser_id);
  }

  String generateNewOrderId(String user_id) {
    String currentMonth = DateFormat('MMM').format(DateTime.now());

    if (currentuser_id != user_id) {
      attendanceOutSerialCounter = attendanceOutHighestSerial??1;
      currentuser_id = user_id;
    }

    if (attendanceOutCurrentMonth != currentMonth) {
      attendanceOutSerialCounter = 1;
      attendanceOutCurrentMonth = currentMonth;
    }

    String orderId =
        "ATD-$user_id-$currentMonth-${attendanceOutSerialCounter.toString().padLeft(3, '0')}";
    attendanceOutSerialCounter++;
    _saveCounter();
    return orderId;
  }


  
  saveFormAttendanceOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    var totalDistance = prefs.getDouble('totalDistance') ?? 0.0;
    var totalTime = prefs.getString('totalTime') ?? 0.0;

     // await  _loadCounter();
    // final orderSerial = generateNewOrderId(user_id);
    final orderSerial = prefs.getString('attendanceId') ?? '';
    addAttendanceOut (AttendanceOutModel(
      attendance_out_id: orderSerial,
      user_id: user_id,
      // time_out: ,
       total_distance: totalDistance,
       total_time:  totalTime,
       // total_time:  locationViewModel.newsecondpassed.value,
      lat_out: locationViewModel.globalLatitude1.value,
      lng_out: locationViewModel.globalLongitude1.value ,
      address: locationViewModel.shopAddress.value,
    ));
    await attendanceOutRepository.postDataFromDatabaseToAPI();
  }
  fetchAllAttendanceOut() async{
    var attendanceOut = await attendanceOutRepository.getAttendanceOut();
    allAttendanceOut.value = attendanceOut;
  }

  addAttendanceOut(AttendanceOutModel attendanceOutModel){
    attendanceOutRepository.add(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  updateAttendanceOut(AttendanceOutModel attendanceOutModel){
    attendanceOutRepository.update(attendanceOutModel);
    fetchAllAttendanceOut();
  }

  deleteAttendanceOut(String id){
    attendanceOutRepository.delete(id);
    fetchAllAttendanceOut();
  }
  serialCounterGet()async{
    await attendanceOutRepository.serialNumberGeneratorApi();
  }
}