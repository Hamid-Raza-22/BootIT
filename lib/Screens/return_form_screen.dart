import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:order_booking_app/Models/returnform_details_model.dart';
import '../Models/ScreenModels/return_form_model.dart';
import '../ViewModels/ScreenViewModels/return_form_view_model.dart';
import '../ViewModels/return_form_details_view_model.dart';
import '../ViewModels/return_form_view_model.dart';
import 'ReturnFormScreenComponents/form_row.dart';
import 'ReturnFormScreenComponents/return_appbar.dart';

class ReturnFormScreen extends StatelessWidget {
 ReturnFormScreen({super.key});
  final ReturnFormViewModel viewModel = Get.put(ReturnFormViewModel());
 final ReturnFormDetailsViewModel returnFormDetailsViewModel =
 Get.put(ReturnFormDetailsViewModel());
  @override
  Widget build(BuildContext context) {
    viewModel.initializeData();
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                Obx(() {
                  // Debug: Print the contents of viewModel.shops
                  debugPrint("Shops in ViewModel: ${viewModel.shops}");
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Shop Name",
                      labelStyle: TextStyle(fontSize: 15),
                      border: UnderlineInputBorder(),
                    ),
                    value: viewModel.selectedShop.value.isEmpty
                        ? null
                        : viewModel.selectedShop.value,
                    items: viewModel.shops.map((shop) {
                      // Debug: Print each shop name being added to the dropdown
                      debugPrint("Adding Shop to Dropdown: ${shop.name}");
                      return DropdownMenuItem(
                        value: shop.name,
                        child: Text(shop.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      viewModel.selectedShop.value = value!;

                    },
                  );
                }),
                const SizedBox(height: 30),
                Obx(() => Column(
                      children: returnFormDetailsViewModel.formRows
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        ReturnForm row = entry.value;
                        return FormRow(
                            size: size,
                            returnFormDetailsViewModel:
                                returnFormDetailsViewModel,
                            row: row,
                            index: index);
                      }).toList(),
                    )),
                const SizedBox(height: 30),
                 AddRowButton(),
                const SizedBox(height: 40),
                const SubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShopDropdown extends StatelessWidget {
  final Size size;
  final ReturnFormViewModel viewModel;

  ShopDropdown({required this.size, required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    viewModel.initializeData();
    return Obx(() => SizedBox(
      width: size.width * 0.8,
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: "Select Shop *",
          labelStyle: TextStyle(fontSize: 18),
          border: UnderlineInputBorder(),
        ),
        value: viewModel.selectedShop.value.isEmpty
            ? null
            : viewModel.selectedShop.value,
        items: viewModel.shops.map((shop) {
          return DropdownMenuItem<String>(
            value: shop.name,
            child: Text(shop.name),
          );
        }).toList(),
        onChanged: (value) {
          viewModel.selectedShop.value = value!;
        },
      ),
    ));
  }
}

class AddRowButton extends StatelessWidget {
  AddRowButton({super.key});
  final ReturnFormDetailsViewModel returnFormDetailsViewModel =
      Get.put(ReturnFormDetailsViewModel());

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    return ElevatedButton(
      onPressed: returnFormDetailsViewModel.addRow,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Add Row',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ReturnFormViewModel viewModel = Get.find();
    return ElevatedButton(
      onPressed: viewModel.submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        'Submit',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
