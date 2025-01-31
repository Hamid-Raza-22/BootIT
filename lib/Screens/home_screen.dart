import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ProductsViewModel.dart';
import 'package:order_booking_app/ViewModels/shop_visit_details_view_model.dart';
import 'package:order_booking_app/screens/add_shop_screen.dart';
import 'package:order_booking_app/screens/order_booking_status_screen.dart';
import 'package:order_booking_app/screens/recovery_form_screen.dart';
import 'package:order_booking_app/screens/return_form_screen.dart';
import 'package:order_booking_app/screens/shop_visit_screen.dart';
import 'package:rive/rive.dart';
import 'HomeScreenComponents/action_box.dart';
import 'HomeScreenComponents/assets.dart ';
import 'HomeScreenComponents/navbar.dart';
import 'HomeScreenComponents/overview_row.dart';
import 'HomeScreenComponents/profile_section.dart';
import 'HomeScreenComponents/theme.dart';

import 'HomeScreenComponents/timer_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _RiveAppHomeState();
}

class _RiveAppHomeState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ShopVisitDetailsViewModel shopVisitDetailsViewModel = Get.put(ShopVisitDetailsViewModel());
  // ProductsViewModel productsViewModel = Get.put(ProductsViewModel());
  late AnimationController? _animationController;
  late AnimationController? _onBoardingAnimController;
  late Animation<double> _onBoardingAnim;
  late Animation<double> _sidebarAnim;
  late SMIBool _menuBtn;
   Widget _tabBody = Container(color: RiveAppTheme.backgroundLight);

  final springDesc = const SpringDescription(
    mass: 0.1,
    stiffness: 40,
    damping: 5,
  );
  bool _showOnBoarding = false;
  void _onMenuIconInit(Artboard artboard) {
    final controller =
    StateMachineController.fromArtboard(artboard, "State Machine");
    artboard.addController(controller!);
    _menuBtn = controller.findInput<bool>("isOpen") as SMIBool;
    _menuBtn.value = true;
  }

  void _presentOnBoarding(bool show) {
    if (show) {
      setState(() {
        _showOnBoarding = true;
      });
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _onBoardingAnimController?.animateWith(springAnim);
    } else {
      _onBoardingAnimController?.reverse().whenComplete(() => {
        setState(() {
          _showOnBoarding = false;
        })
      });
    }
  }

  void onMenuPress() {
    if (_menuBtn.value) {
      final springAnim = SpringSimulation(springDesc, 0, 1, 0);
      _animationController?.animateWith(springAnim);
    } else {
      _animationController?.reverse();
    }
    _menuBtn.change(!_menuBtn.value);

    SystemChrome.setSystemUIOverlayStyle(_menuBtn.value
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light);
  }
  // final List<Widget> _screens = [
  //   const HomeTabView(),
  //   commonTabScene("User"),
  //   commonTabScene("User"),
  //   commonTabScene("User"),
  //
  // ];
  @override
  void initState() {

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      upperBound: 1,
      vsync: this,
    );
    _onBoardingAnimController = AnimationController(
      duration: const Duration(milliseconds: 350),
      upperBound: 1,
      vsync: this,
    );

    _sidebarAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _onBoardingAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _onBoardingAnimController!,
      curve: Curves.linear,
    ));

    // _tabBody = _screens.first;
    super.initState();
    // productsViewModel.fetchAndSaveProducts();
    //
    // shopVisitDetailsViewModel.initializeProductData();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _onBoardingAnimController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 1),
              TimerCard(), // Add the TimerCard here
              const SizedBox(height: 3),
              _buildActionButtons(screenWidth),
              const SizedBox(height: 20),
              _buildOverviewSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header, including navbar and profile section.
  Widget _buildHeader() {
    return Container(
      color: Colors.blue,
      child: const Column(
        children: [
          Navbar(),
          SizedBox(height: 10),
          ProfileSection(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Builds the section with action buttons.
  Widget _buildActionButtons(double screenWidth) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ActionBox(imagePath: add_shop, label: 'Add Shop',onTap:() => Get.to(() => AddShopScreen()),
              ),
              ActionBox(imagePath: shop_visit, label: 'Shop Visit',onTap:  () => Get.to(() => ShopVisitScreen()),
              ),
              ActionBox(imagePath: return_form, label: 'Return Form',onTap:  () => Get.to(() => const ReturnFormScreen()),
              ),
              ActionBox(imagePath: recovery2, label: 'Recovery',onTap:  () => Get.to(() =>  RecoveryFormScreen()),
              ),
              ActionBox(imagePath: order_booking_status, label: 'Booking Status', onTap:  () => Get.to(() =>  OrderBookingStatusScreen()),
              ),
            ],
          ),
          // SizedBox(height: 20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //
          //
          //   ],
          // ),
        ],
      ),
    );
  }

  /// Builds the overview section with summary boxes.
  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overview",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.8),
                  spreadRadius: 3,
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              children: [
                OverviewRow(
                  numbers: ["123", "45", "67", "89"],
                  labels: ["Total Bookings", "Shops", "Returns", "Visits"],
                ),
                SizedBox(height: 20),
                OverviewRow(
                  numbers: ["12", "34", "56", "78"],
                  labels: ["Monthly Attendance", "Daily Bookings", "Orders", "Recovery"],
                ),
                SizedBox(height: 20),
                OverviewRow(
                  numbers: ["910", "112"],
                  labels: ["Total Orders", "Dispatched"],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




