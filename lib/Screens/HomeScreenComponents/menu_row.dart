import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_booking_app/Screens/HomeScreenComponents/theme.dart';
import 'package:order_booking_app/screens/HomeScreenComponents/assets.dart' as app_assets;
import 'package:rive/rive.dart';

import 'menu_item.dart';

class MenuRow extends StatelessWidget {
  const MenuRow({
    Key? key,
    required this.menu,
    this.selectedMenu = "Home",
    this.onMenuPress,
  }) : super(key: key);

  final MenuItemModel menu;
  final String selectedMenu;
  final Function? onMenuPress;

  void _onMenuIconInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      menu.riveIcon.stateMachine,
    );
    artboard.addController(controller!);
    menu.riveIcon.status = controller.findInput<bool>("active") as SMIBool?;
  }

  void onMenuPressed(BuildContext context) {
    if (selectedMenu != menu.title) {
      onMenuPress?.call();

      menu.riveIcon.status?.change(true);
      Future.delayed(const Duration(seconds: 1), () {
        menu.riveIcon.status?.change(false);
      });

      // Navigation logic
      if (menu.screen != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => menu.screen!),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: selectedMenu == menu.title ? 418 - 16 : 0,
          height: 56,
          curve: const Cubic(0.2, 0.8, 0.2, 1),
          decoration: BoxDecoration(
            color: RiveAppTheme.orange,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          pressedOpacity: 1,
          onPressed: () => onMenuPressed(context),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Opacity(
                  opacity: 0.6,
                  child: RiveAnimation.asset(
                    app_assets.iconsRiv,
                    stateMachines: [menu.riveIcon.stateMachine],
                    artboard: menu.riveIcon.artboard,
                    onInit: _onMenuIconInit,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                menu.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
