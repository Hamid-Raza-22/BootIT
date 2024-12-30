import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../login_screen.dart';
import '../Components/WidgetsComponents/contect_widget.dart';
import '../Components/WidgetsComponents/custom_button.dart';
import '../Components/WidgetsComponents/header_widget.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Static content for the screen
    const IconData icon = Icons.storage_rounded;
    const String headerText = "Storage Permission";
    const String descriptionText =
        "Grant storage access to save and retrieve files during app usage.";

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          // Header Widget
          Positioned(
            bottom: screenHeight * 0.6,
            top: 0,
            left: 0,
            right: 0,
            child: HeaderWidget(
              icon: icon,
              screenWidth: screenWidth,
            ),
          ),
          // Content Widget
          Positioned(
            top: screenHeight * 0.4,
            left: 0,
            right: 0,
            child: ContentWidget(
              headerText: headerText,
              descriptionText: descriptionText,
              highlightedIndex: 6,
            ),
          ),
          // Custom Button
          Positioned(
            bottom: screenHeight * 0.05,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: CustomButton(
              buttonText: 'ALLOW',
              onPressed: () async {
                   Get.to(() => const LoginScreen());

                // Request storage permission
                // PermissionStatus storageStatus =
                // await Permission.storage.request();
                //
                // if (storageStatus.isGranted) {
                //   // Navigate to the LoginScreen if permission is granted
                //   Get.to(() => const LoginScreen());
                // } else {
                //   // Show a snackbar if permission is denied
                //   Get.snackbar(
                //     'Permission Denied',
                //     'You need to allow storage permission to proceed.',
                //     snackPosition: SnackPosition.BOTTOM,
                //     backgroundColor: Colors.redAccent,
                //     colorText: Colors.white,
                //   );
                // }
              },
            ),
          ),
        ],
      ),
    );
  }
}
