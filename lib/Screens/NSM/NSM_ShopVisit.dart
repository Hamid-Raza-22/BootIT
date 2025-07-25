import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';


import '../../Databases/util.dart';
import '../../Models/HeadsShopVistModels.dart';


import '../../ViewModels/add_shop_view_model.dart';
import '../../ViewModels/location_view_model.dart';
import '../../ViewModels/login_view_model.dart';
import '../../ViewModels/shop_visit_view_model.dart';
import 'nsm_homepage.dart';



class NSMShopVisitPage extends StatefulWidget {
  const NSMShopVisitPage({
    Key? key,
  }) : super(key: key);

  @override
  NSMShopVisitPageState createState() => NSMShopVisitPageState();
}

class NSMShopVisitPageState extends State<NSMShopVisitPage> {
  TextEditingController regionController = TextEditingController();
  TextEditingController bookerController = TextEditingController();
  TextEditingController shopController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  bool isGpsEnabled = false;
  bool isLoadingLocation = false; // Loading state variable

  dynamic globalLatitude = '';
  dynamic globalLongitude = '';
  bool isLocationFetched = false;
  bool isLocationChecked = false; // Checkbox state
  final loginViewModel = Get.put(LoginViewModel());
  final locationViewModel = Get.put(LocationViewModel());
  final shopVisitViewModel = Get.put(ShopVisitViewModel());
  List<String> dropdownItems = [];
  List<String> bookersDropdownItems = [];
  List<String> citiesDropdownItems = [];
  final TextEditingController NSMNameController = TextEditingController(text: userName);
  final String currentDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  final AddShopViewModel _viewModel = Get.put(AddShopViewModel());


  @override
  void initState() {
    super.initState();
    shopVisitViewModel.fetchBrands();
    shopVisitViewModel.fetchShops();
    loginViewModel.fetchBookerIds("nsm_id");
    debugPrint('userDesignation: $user_id');
    // Debug: Print the bookers list
    debugPrint('Bookers list for dropdown: ${loginViewModel.bookers.value}');
    // shopVisitDetailsViewModel.initializeProductData();
  }


  bool isSwitchDisabled = false; // Add this state variable

  Future<void> saveCurrentLocation(BuildContext context) async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      isLoadingLocation = true; // Start loading
      isSwitchDisabled = true;  // Disable the switch while loading
    });

    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        globalLatitude = position.latitude;
        globalLongitude = position.longitude;

        if (kDebugMode) {
          print('Latitude: $globalLatitude, Longitude: $globalLongitude');
        }

        // Default address to "Pakistan" initially
        String address1 = "Pakistan";

        try {
          // Attempt to get the address from coordinates
          List<Placemark> placemarks = await placemarkFromCoordinates(
              globalLatitude!, globalLongitude!);
          Placemark? currentPlace = placemarks.isNotEmpty ? placemarks[0] : null;

          if (currentPlace != null) {
            address1 = "${currentPlace.thoroughfare ?? ''} ${currentPlace.subLocality ?? ''}, ${currentPlace.locality ?? ''} ${currentPlace.postalCode ?? ''}, ${currentPlace.country ?? ''}";

            // Check if the constructed address is empty, fallback to "Pakistan"
            if (address1.trim().isEmpty) {
              address1 = "Pakistan";
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error getting placemark: $e');
          }
          // Keep the address as "Pakistan"
        }

        shopAddress = address1;
        isLocationFetched = true; // Set location fetched to true
        isGpsEnabled = true; // GPS is enabled

        if (kDebugMode) {
          print('Address is: $address1');
        }

      } catch (e) {
        if (kDebugMode) {
          print('Error getting location: $e');
        }
        isGpsEnabled = false; // GPS is not enabled
      }
    } else {
      if (kDebugMode) {
        print('Location permission is not granted');
      }
      // Ensure GPS remains disabled
      isGpsEnabled = false;
      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NSMHomepage()),
      );
    }

    if (!mounted) return; // Check again before calling setState()
    setState(() {
      isLoadingLocation = false; // Stop loading
      isSwitchDisabled = false;  // Re-enable the switch after loading
    });
  }

  Widget _buildGpsStatusWidget() {
    return Row(
      children: [
        Switch(
          value: isGpsEnabled,
          onChanged: isSwitchDisabled
              ? null // Disable interaction when switch is disabled
              : (bool value) async {
            if (value) {
              await saveCurrentLocation(context);
            } else {
              setState(()
              {
                isGpsEnabled = false;
              });
            }
          },
          activeColor: Colors.blue,
        ),
        const Text(
          'GPS Enabled',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }




  bool _isSubmitButtonEnabled() {
    return isLocationFetched &&
        regionController.text.isNotEmpty &&
        bookerController.text.isNotEmpty &&
        shopController.text.isNotEmpty &&
        feedbackController.text.isNotEmpty;
  }

  // void _showToast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0
  //   );
  // }



  Future<void> onDropdownTapRegion() async {
    // await fetchCitiesNames();
  }
  Future<void> onDropdownTapBooker() async {
   // await fetchBookerNamesByNSMDesignation();
  }
  Future<void> onDropdownTapShop() async {
    // await _checkUserIdAndFetchShopNames();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Visit Form'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedTextField('NSM Name', NSMNameController, Icons.person, readOnly: true),
            const SizedBox(height: 16),
            buildAnimatedDateField(currentDate),
            const SizedBox(height: 16),
            _buildAnimatedDropdown(
                "Select City", _viewModel.cities.value, Icons.location_on,
                regionController, onDropdownTapRegion),
            const SizedBox(height: 16),
            Obx(() {
              return
                _buildAnimatedDropdown(
                  "Select Booker ID",
                  loginViewModel.bookers.value
                      .where((userId) => userId != null)
                      .cast<String>()
                      .toList(),
                  Icons.book,
                  bookerController,
                  onDropdownTapBooker,
                );

              // Debug: Print the bookers list
              debugPrint('Bookers list for dropdown: ${loginViewModel.bookers.value}');
            }),
            const SizedBox(height: 16),
            Obx(() {
              return _buildAnimatedDropdown(
                  "Select Shop", shopVisitViewModel.shops.value
                  .where((shop) => shop != null)
                  .cast<String>()
                  .toList(),
                  Icons.store, shopController, onDropdownTapShop);
            }),
            const SizedBox(height: 16),
            _buildAnimatedFeedbackBox(),
            const SizedBox(height: 10),
            _buildGpsStatusWidget(),
            const SizedBox(height: 24),
            _buildAnimatedSubmitButton(context),
          ],
        ),
      ),
    );
  }


  Widget _buildAnimatedTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue),
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  buildAnimatedDateField(String currentDate) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: TextEditingController(text: currentDate),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
            labelText: 'Date',
            border: InputBorder.none,
          ),
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown(String label, List<String> items, IconData icon, TextEditingController controller, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownSearch<String>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
          items: items,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue),
              labelText: label,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
          onChanged: (value) {
            controller.text = value ?? '';
            setState(() {}); // Update the state to recheck the button enable status
          },
        ),
      ),
    ),
    );
  }

  Widget _buildAnimatedFeedbackBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback or Note',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your feedback here...',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              onChanged: (value) => setState(() {}), // Recheck button enable status
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  feedbackController.clear();
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: _isSubmitButtonEnabled()
            ? () async {
          await _handleLogin();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form Submitted Successfully'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.pop(context);
        }
            : null
        //     () {
        //   _showToast('Please fill all fields and make sure location is enabled.');
        // }
        , // Disable button if not enabled
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          elevation: 8,
        ),
        child: const Text('Submit'),
      ),
    );
  }

  Future<void> _handleLogin() async {
    await shopVisitViewModel.loadCounterHeads();
    final orderSerial = await shopVisitViewModel.generateNewOrderIdHeads(user_id);

    await shopVisitViewModel.addHeadsShopVisit(HeadsShopVisitModel(
      shop_visit_master_id: orderSerial,
      shop_name: shopController.text,
      user_id: user_id,
      booker_name: NSMNameController.text,
      booker_id: bookerController.text,
      city: regionController.text,
      feedback: feedbackController.text,
      shop_address: locationViewModel.shopAddress.value,
    ));
    await shopVisitViewModel.postHeadsShopVisit();
  }
}
