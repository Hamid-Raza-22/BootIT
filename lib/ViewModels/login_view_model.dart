import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/LoginModels/login_models.dart';
import '../Databases/dp_helper.dart';
import '../Databases/util.dart';
import '../Repositories/LoginRepositories/login_repository.dart';


class LoginViewModel extends GetxController {

  var allLogin = <LoginModels>[].obs;
  // var bookers = <LoginModels>[].obs;
  LoginRepository loginRepository = LoginRepository();
  DBHelper dbHelper = Get.put(DBHelper());
  var isAuthenticated = false.obs; // To track login status
  var bookers = <dynamic>[].obs; // Change this line
  var bookersId =  <LoginModels>[].obs; // Change this line


  @override
  void onInit(){
    // TODO: implement onInit
    super.onInit();
    //fetchAllLight();
    // _checkInternetBeforeNavigation();
  }
  fetchBookerNamesBySMDesignation() async {

    var smnames = await loginRepository.getBookerNamesBySMDesignation();
    bookers.value = smnames;

  }
  Future<void> fetchBookerIds() async {
    try {
      debugPrint('Fetching booker IDs...');
      //var savedShops = await loginRepository.getLogin();
      var savedShops = await loginRepository.getBookerNamesByDesignation('sm_id', user_id);
      debugPrint('Fetched booker IDs: ${savedShops.map((e) => e.user_id).toList()}');

      bookers.value = savedShops.map((userIds) => userIds.user_id).toList();
      bookersId.value = savedShops;

      debugPrint('Bookers list for dropdown: ${bookers.value}');
    } catch (e) {
      debugPrint('Failed to fetch bookers: $e');
    }
  }
  // fetchBookerNamesBySMDesignation() async {
  //   var smnames = await loginRepository.getBookerNamesBySMDesignation();
  //   bookers.value = smnames;
  // }
  // Future<void> fetchBookerIds() async {
  //   try {
  //     var savedShops = await loginRepository.getBookerNamesByDesignation('SM_ID', user_id);
  //     bookers.value = savedShops.map((userIds) => userIds.user_id).toList();
  //     allLogin.value =
  //         savedShops; // Update this line to store full shop details
  //   } catch (e) {
  //     debugPrint('Failed to fetch shops: $e');
  //   }
  // }

  // Method to check the internet connection before navigating to the login page
  Future<void> checkInternetBeforeNavigation() async {
    bool hasInternet = await isNetworkAvailable();

    if (!hasInternet) {


      // Show a GetX Snackbar with an internet error message
      Get.snackbar(
        'Internet Error',
        'No internet connection. The app will close shortly.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      // Delay for a few seconds before closing the app to allow user to see the message
      await Future.delayed(Duration(seconds: 5));
      exit(0); // Close the app if no internet connection
    } else {
      await fetchAndSaveLoginData();

    }
  }
  Future<void> checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated.value = prefs.getBool('isAuthenticated') ?? false;
  }
  // Future<bool> login(String userId, String password) async {
  //   await fetchAllLogin(); // Ensure the latest data is fetched
  //
  //   // Check if the user exists and password matches
  //   for (var loginModel in allLogin) {
  //     if (loginModel.user_id == userId && loginModel.password == password) {
  //       isAuthenticated.value = true; // Set login status
  //       return true; // Login successful
  //     }
  //   }
  //   isAuthenticated.value = false; // Set login status
  //   return false; // Login failed
  // }
  Future<bool> login(String userId, String password) async {
    try {
      // Step 1: Authenticate user
      final user = await loginRepository.getUserByCredentials(userId, password);

      if (user == null) {
        isAuthenticated.value = false; // Set login status to false
        return false; // Login failed
      }

      // Step 2: Fetch user details
      var userDetails = await loginRepository.getUserDetailsById(userId);
      if (userDetails == null) {
        isAuthenticated.value = false; // Set login status to false
        return false; // Login failed (user details not found)
      }

      // Step 3: Extract and store user details
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      // Store user details in SharedPreferences
      await prefs.setString('userName', userDetails['user_name'] ?? "");
      await prefs.setString('userCity', userDetails['city'] ?? "");
      await prefs.setString('userDesignation', userDetails['designation'] ?? "");
      await prefs.setString('userBrand', userDetails['brand'] ?? "");
      await prefs.setString('userRSM', userDetails['rsm_id'] ?? "");
      await prefs.setString('userSM', userDetails['sm_id'] ?? "");
      await prefs.setString('userNSM', userDetails['nsm_id'] ?? "");
      await prefs.setString('userNameNSM', userDetails['nsm'] ?? "");
      await prefs.setString('userNameRSM', userDetails['rsm'] ?? "");
      await prefs.setString('userNameSM', userDetails['sm'] ?? "");



      // Log user details for debugging
      debugPrint("City: ${userDetails['city']}");
      debugPrint("User Name: ${userDetails['user_name']}");
      debugPrint("Designation: ${userDetails['designation']}");
      debugPrint("Brand: ${userDetails['brand']}");
      debugPrint("RSM: ${userDetails['rsm']}");
      debugPrint("SM: ${userDetails['sm']}");
      debugPrint("NSM: ${userDetails['nsm']}");
      debugPrint("RSM ID: ${userDetails['rsm_id']}");
      debugPrint("SM ID: ${userDetails['sm_id']}");
      debugPrint("NSM ID: ${userDetails['nsm_id']}");

      await _loginRetrieveSavedValues();
      // Step 4: Set authentication state
      isAuthenticated.value = true; // Set login status to true
      await prefs.setBool('isAuthenticated', true);

      return true; // Login successful
    } catch (e) {
      // Handle any errors that occur during the login process
      debugPrint("Login failed with error: $e");
      isAuthenticated.value = false; // Set login status to false
      return false; // Login failed
    }
  }
  navigateToHomePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userDesignation = prefs.getString('userDesignation') ?? '';
    switch (userDesignation) {
      case 'RSM':
        pageName = "/RSMHomepage";
        Get.offNamed("/RSMHomepage");
        break;
      case 'SM':
        pageName = "/SMHomepage";
        Get.offNamed("/SMHomepage");
        break;
      case 'NSM':
        pageName = "/NSMHomepage";
        Get.offNamed("/NSMHomepage");
        break;
      default:
        pageName = "/home";
        Get.offNamed("/home");
        break;
    }

    // Save the pageName in SharedPreferences
    await prefs.setString('pageName', pageName);
  }
  _loginRetrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

      user_id = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      userCity = prefs.getString('userCity') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      userBrand = prefs.getString('userBrand') ?? '';
      userSM = prefs.getString('userSM') ?? '';
      userNSM = prefs.getString('userNSM') ?? '';
      userRSM = prefs.getString('userRSM') ?? '';

  }

  logout() async {
    isAuthenticated.value = false; // Set login status to false

    // Clear authentication state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
    await prefs.remove("userId");

    // Clear the data from all tables
    await dbHelper.clearData();
  }

  fetchAllLogin() async{
    var login = await loginRepository.getLogin();
    allLogin.value = login;
  }
  // Add these methods for booker names
 getBookerNamesByRSMDesignation() async {
      var bookers = await loginRepository.getBookerNamesByDesignation('rsm_id',user_id );
      // bookers.value = bookers;
  }

  fetchAndSaveLoginData() async {
    await loginRepository.fetchAndSaveLogin();
    fetchAllLogin();
  }
  addLogin(LoginModels loginModels){
    loginRepository.add(loginModels);
  }

  updateLogin(LoginModels loginModels){
    loginRepository.update(loginModels);
    fetchAllLogin();
  }

  deleteLogin(int id){
    loginRepository.delete(id);
    fetchAllLogin();
  }

}

