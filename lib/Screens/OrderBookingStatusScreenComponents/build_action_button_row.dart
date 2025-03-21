import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
import '../../ViewModels/order_master_view_model.dart';
import '../../ViewModels/shop_visit_view_model.dart';
import '../../Databases/dp_helper.dart';

List<DataRow> dataRows = [];
OrderBookingStatusViewModel orderBookingStatusViewModel =
Get.put(OrderBookingStatusViewModel());
String _getFormattedDate() {
  return DateFormat('dd-MMM-yyyy').format(DateTime.now());
}

Widget buildActionButtonsRow(OrderBookingStatusViewModel viewModel) {
  OrderDetailsViewModel orderDetailsViewModel =
  Get.put(OrderDetailsViewModel());
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  final OrderMasterViewModel orderMasterViewModel =
  Get.find<OrderMasterViewModel>();

  // Define a footer
  pw.Widget buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Developed By MetaXperts!',
        style: pw.TextStyle(
          fontSize: 12,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey,
        ),
      ),
    );
  }

  // Generate Order PDF
  // Future<void> generateOrderPDF() async {
  //   final pdf = pw.Document();
  //   String currentDate = _getFormattedDate();
  //   String ordersDate = (orderBookingStatusViewModel.endDate.value != null)
  //       ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
  //       : 'Date Not Selected';
  //
  //   // Get and trim selected status before fetch
  //   String selectedStatus = orderBookingStatusViewModel.selectedStatus.value.trim();
  //   debugPrint('Selected Status: "$selectedStatus"');
  //
  //   // Fetch order data first
  //   await orderMasterViewModel.fetchAllOrderMaster();
  //
  //   // Log number of orders fetched
  //   debugPrint('Total Orders Fetched: ${orderMasterViewModel.allOrderMaster.length}');
  //
  //   // Log all order statuses
  //   var allStatuses = orderMasterViewModel.allOrderMaster
  //       .map((order) => (order.order_status ?? '').trim())
  //       .toSet();
  //   debugPrint('Unique Statuses in Orders: $allStatuses');
  //
  //   // Filter orders with comparison logs
  //   var filteredOrders = orderMasterViewModel.allOrderMaster.where((order) {
  //     String orderStatus = (order.order_status ?? '').trim().toLowerCase();
  //     bool isMatch = orderStatus == selectedStatus.toLowerCase();
  //     debugPrint(
  //         'Order ID: ${order.order_master_id}, Status: "$orderStatus" == "$selectedStatus" ? $isMatch');
  //     return isMatch;
  //   }).toList();
  //
  //   debugPrint('Filtered Orders Count: ${filteredOrders.length}');
  //
  //   if (filteredOrders.isEmpty) {
  //     Get.snackbar('No Orders Found', 'No orders with status "$selectedStatus" found.');
  //     return;
  //   }
  //
  //   // Prepare table data
  //   List<List<String>> rowsData = [];
  //   double totalAmount = 0.0;
  //   int totalOrders = filteredOrders.length;
  //
  //   for (var order in filteredOrders) {
  //     String amountText =
  //     (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), ''); // remove non-numeric
  //     double amount = double.tryParse(amountText) ?? 0.0;
  //     totalAmount += amount;
  //     rowsData.add([
  //       order.order_master_id ?? '-',
  //       order.shop_name ?? '-',
  //       'PKR $amountText',
  //     ]);
  //   }
  //
  //   // Generate PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('Valor Trading Order Booking Status',
  //                 style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 10),
  //             pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id}'),
  //             pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
  //             pw.Text('Print Date: $currentDate'),
  //             pw.Text('Orders Date: $ordersDate'),
  //             pw.Text('Status: $selectedStatus'),
  //             pw.SizedBox(height: 10),
  //             pw.Table.fromTextArray(
  //               headers: ['Order No', 'Shop Name', 'Amount'],
  //               data: rowsData,
  //               headerStyle: pw.TextStyle(
  //                   fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
  //               headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
  //               cellStyle: const pw.TextStyle(fontSize: 10),
  //               cellAlignment: pw.Alignment.center,
  //               cellPadding: const pw.EdgeInsets.all(6),
  //               oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //               border: null,
  //             ),
  //             pw.Divider(),
  //             pw.Text('Total Orders: $totalOrders',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             buildFooter(),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Save & Share PDF
  //   try {
  //     final directory = await getTemporaryDirectory();
  //     final filePath =
  //         '${directory.path}/Order_Booking_Status_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     final xfile = XFile(filePath);
  //     await Share.shareXFiles([xfile], text: 'Order Booking PDF Document');
  //     Get.snackbar('Success', 'Order PDF shared successfully!');
  //   } catch (e) {
  //     debugPrint("Error saving or sharing Order PDF: $e");
  //     Get.snackbar('Error', 'Failed to generate or share Order PDF.');
  //   }
  // }  // Future<void> generateOrderPDF() async {
  //   final pdf = pw.Document();
  //   String currentDate = _getFormattedDate();
  //   String ordersDate = (orderBookingStatusViewModel.endDate.value != null)
  //       ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
  //       : 'Date Not Selected';
  //
  //   // Get and trim selected status before fetch
  //   String selectedStatus = orderBookingStatusViewModel.selectedStatus.value.trim();
  //   debugPrint('Selected Status: "$selectedStatus"');
  //
  //   // Fetch order data first
  //   await orderMasterViewModel.fetchAllOrderMaster();
  //
  //   // Log number of orders fetched
  //   debugPrint('Total Orders Fetched: ${orderMasterViewModel.allOrderMaster.length}');
  //
  //   // Log all order statuses
  //   var allStatuses = orderMasterViewModel.allOrderMaster
  //       .map((order) => (order.order_status ?? '').trim())
  //       .toSet();
  //   debugPrint('Unique Statuses in Orders: $allStatuses');
  //
  //   // Filter orders with comparison logs
  //   var filteredOrders = orderMasterViewModel.allOrderMaster.where((order) {
  //     String orderStatus = (order.order_status ?? '').trim().toLowerCase();
  //     bool isMatch = orderStatus == selectedStatus.toLowerCase();
  //     debugPrint(
  //         'Order ID: ${order.order_master_id}, Status: "$orderStatus" == "$selectedStatus" ? $isMatch');
  //     return isMatch;
  //   }).toList();
  //
  //   debugPrint('Filtered Orders Count: ${filteredOrders.length}');
  //
  //   if (filteredOrders.isEmpty) {
  //     Get.snackbar('No Orders Found', 'No orders with status "$selectedStatus" found.');
  //     return;
  //   }
  //
  //   // Prepare table data
  //   List<List<String>> rowsData = [];
  //   double totalAmount = 0.0;
  //   int totalOrders = filteredOrders.length;
  //
  //   for (var order in filteredOrders) {
  //     String amountText =
  //     (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), ''); // remove non-numeric
  //     double amount = double.tryParse(amountText) ?? 0.0;
  //     totalAmount += amount;
  //     rowsData.add([
  //       order.order_master_id ?? '-',
  //       order.shop_name ?? '-',
  //       'PKR $amountText',
  //     ]);
  //   }
  //
  //   // Generate PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('Valor Trading Order Booking Status',
  //                 style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 10),
  //             pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id}'),
  //             pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
  //             pw.Text('Print Date: $currentDate'),
  //             pw.Text('Orders Date: $ordersDate'),
  //             pw.Text('Status: $selectedStatus'),
  //             pw.SizedBox(height: 10),
  //             pw.Table.fromTextArray(
  //               headers: ['Order No', 'Shop Name', 'Amount'],
  //               data: rowsData,
  //               headerStyle: pw.TextStyle(
  //                   fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
  //               headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
  //               cellStyle: const pw.TextStyle(fontSize: 10),
  //               cellAlignment: pw.Alignment.center,
  //               cellPadding: const pw.EdgeInsets.all(6),
  //               oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //               border: null,
  //             ),
  //             pw.Divider(),
  //             pw.Text('Total Orders: $totalOrders',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             buildFooter(),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Save & Share PDF
  //   try {
  //     final directory = await getTemporaryDirectory();
  //     final filePath =
  //         '${directory.path}/Order_Booking_Status_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     final xfile = XFile(filePath);
  //     await Share.shareXFiles([xfile], text: 'Order Booking PDF Document');
  //     Get.snackbar('Success', 'Order PDF shared successfully!');
  //   } catch (e) {
  //     debugPrint("Error saving or sharing Order PDF: $e");
  //     Get.snackbar('Error', 'Failed to generate or share Order PDF.');
  //   }
  // }  // Future<void> generateOrderPDF() async {
  //   final pdf = pw.Document();
  //   String currentDate = _getFormattedDate();
  //   String ordersDate = (orderBookingStatusViewModel.endDate.value != null)
  //       ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
  //       : 'Date Not Selected';
  //
  //   // Get and trim selected status before fetch
  //   String selectedStatus = orderBookingStatusViewModel.selectedStatus.value.trim();
  //   debugPrint('Selected Status: "$selectedStatus"');
  //
  //   // Fetch order data first
  //   await orderMasterViewModel.fetchAllOrderMaster();
  //
  //   // Log number of orders fetched
  //   debugPrint('Total Orders Fetched: ${orderMasterViewModel.allOrderMaster.length}');
  //
  //   // Log all order statuses
  //   var allStatuses = orderMasterViewModel.allOrderMaster
  //       .map((order) => (order.order_status ?? '').trim())
  //       .toSet();
  //   debugPrint('Unique Statuses in Orders: $allStatuses');
  //
  //   // Filter orders with comparison logs
  //   var filteredOrders = orderMasterViewModel.allOrderMaster.where((order) {
  //     String orderStatus = (order.order_status ?? '').trim().toLowerCase();
  //     bool isMatch = orderStatus == selectedStatus.toLowerCase();
  //     debugPrint(
  //         'Order ID: ${order.order_master_id}, Status: "$orderStatus" == "$selectedStatus" ? $isMatch');
  //     return isMatch;
  //   }).toList();
  //
  //   debugPrint('Filtered Orders Count: ${filteredOrders.length}');
  //
  //   if (filteredOrders.isEmpty) {
  //     Get.snackbar('No Orders Found', 'No orders with status "$selectedStatus" found.');
  //     return;
  //   }
  //
  //   // Prepare table data
  //   List<List<String>> rowsData = [];
  //   double totalAmount = 0.0;
  //   int totalOrders = filteredOrders.length;
  //
  //   for (var order in filteredOrders) {
  //     String amountText =
  //     (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), ''); // remove non-numeric
  //     double amount = double.tryParse(amountText) ?? 0.0;
  //     totalAmount += amount;
  //     rowsData.add([
  //       order.order_master_id ?? '-',
  //       order.shop_name ?? '-',
  //       'PKR $amountText',
  //     ]);
  //   }
  //
  //   // Generate PDF
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Text('Valor Trading Order Booking Status',
  //                 style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
  //             pw.SizedBox(height: 10),
  //             pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id}'),
  //             pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
  //             pw.Text('Print Date: $currentDate'),
  //             pw.Text('Orders Date: $ordersDate'),
  //             pw.Text('Status: $selectedStatus'),
  //             pw.SizedBox(height: 10),
  //             pw.Table.fromTextArray(
  //               headers: ['Order No', 'Shop Name', 'Amount'],
  //               data: rowsData,
  //               headerStyle: pw.TextStyle(
  //                   fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
  //               headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
  //               cellStyle: const pw.TextStyle(fontSize: 10),
  //               cellAlignment: pw.Alignment.center,
  //               cellPadding: const pw.EdgeInsets.all(6),
  //               oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //               border: null,
  //             ),
  //             pw.Divider(),
  //             pw.Text('Total Orders: $totalOrders',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
  //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //             buildFooter(),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Save & Share PDF
  //   try {
  //     final directory = await getTemporaryDirectory();
  //     final filePath =
  //         '${directory.path}/Order_Booking_Status_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //
  //     final xfile = XFile(filePath);
  //     await Share.shareXFiles([xfile], text: 'Order Booking PDF Document');
  //     Get.snackbar('Success', 'Order PDF shared successfully!');
  //   } catch (e) {
  //     debugPri nt("Error saving or sharing Order PDF: $e");
  //     Get.snackbar('Error', 'Failed to generate or share Order PDF.');
  //   }
  // }





  Future<void> generateOrderPDF() async {
    final pdf = pw.Document();
    String currentDate = _getFormattedDate();
    String ordersDate = (orderBookingStatusViewModel.endDate.value != null)
        ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
        : 'Date Not Selected';

    // Fetch order data
    await orderMasterViewModel.fetchAllOrderMaster();

    List<List<String>> rowsData = [];
    double totalAmount = 0.0;
    int totalOrders = orderMasterViewModel.allOrderMaster.length;

    for (var order in orderMasterViewModel.allOrderMaster) {
      String amountText = (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
      double amount = double.tryParse(amountText) ?? 0.0;
      totalAmount += amount;
      rowsData.add([
        order.order_master_id ?? '-',
        order.shop_name ?? '-',
        amountText,
      ]);
    }

    // Footer Widget
    pw.Widget buildFooter() {
      return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          'Developed By MetaXperts!',
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey,
          ),
        ),
      );
    }

    // Build PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Valor Trading Order Booking Status',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Booker ID: ${orderMasterViewModel.currentuser_id}'),
              pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
              pw.Text('Print Date: $currentDate'),
              pw.Text('Orders Date: $ordersDate'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Order No', 'Shop Name', 'Amount'],
                data: rowsData,
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.center,
                cellPadding: const pw.EdgeInsets.all(6),
                oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                border: null,
              ),
              pw.Divider(),
              pw.Text('Total Orders: $totalOrders',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              buildFooter(),
            ],
          );
        },
      ),
    );

    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/Order_Booking_Status_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      final xfile = XFile(filePath);
      await Share.shareXFiles([xfile], text: 'Order Booking PDF Document');
      Get.snackbar('Success', 'Order PDF shared successfully!');
    } catch (e) {
      debugPrint("Error saving or sharing Order PDF: $e");
      Get.snackbar('Error', 'Failed to generate or share Order PDF.');
    }
  }

  generateProductsPDF() async {
    final pdf = pw.Document();
    String currentDate = _getFormattedDate();
    String ordersDate = 'All Dates'; // No date range, show as 'All Dates'

    if (kDebugMode) {
      print("Generating PDF for all order data.");
    }

    final Database? db = await DBHelper().db;
    if (db == null) {
      print("Database is not initialized!");
      return;
    }

    // Fetch all rows without date filter
    List<Map<String, dynamic>> queryRows = await db.query('orderDetails');
    print("Query Result Rows: ${queryRows.length}"); // Debug log

    List<List<String>> productTableData = queryRows.isNotEmpty
        ? queryRows.map((order) {
      String productName = order['product'] ?? 'N/A';
      String quantity = order['quantity']?.toString() ?? '0';
      return [productName, quantity];
    }).toList()
        : [['No Products Found', '0']];

    int totalOrders = queryRows.length;

    int itemsPerPage = 20;
    int pageCount = (productTableData.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      int startIndex = pageIndex * itemsPerPage;
      int endIndex = (startIndex + itemsPerPage).clamp(0, productTableData.length);
      List<List> currentPageData = productTableData.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Valor Trading Products Details - Page ${pageIndex + 1}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey300,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Booker ID: ${orderDetailsViewModel.currentuser_id}',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Booker Name: ${shopVisitViewModel.booker_name}',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Print Date: $currentDate',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Orders/Products Date: $ordersDate',
                          style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Product Details:',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),

                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Quantity'],
                  data: currentPageData.isNotEmpty
                      ? currentPageData
                      : [['No Products Found', '0']],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey),
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
                  ),
                  cellPadding: const pw.EdgeInsets.all(6),
                ),

                pw.SizedBox(height: 20),
                pw.Divider(),

                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey300,
                  ),
                  child: pw.Text('Total Orders: $totalOrders',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      );
    }

    try {
      final directory = await getTemporaryDirectory();
      final output = File('${directory.path}/Products PDF.pdf');
      await output.writeAsBytes(await pdf.save());
      print("PDF Saved at: ${output.path}, Size: ${await output.length()} bytes"); // Debug file size
      final xfile = XFile(output.path);
      await Share.shareXFiles([xfile], text: 'PDF Document');
    } catch (e) {
      print("Error saving or sharing PDF: $e");
    }
  }


  // Handle PDF generation actions
  void handleButtonAction(String action) async {
    if (action == 'Order PDF') {
      await generateOrderPDF();
    } else if (action == 'Products PDF') {
      await generateProductsPDF();
    }
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      ElevatedButton(
        onPressed: generateOrderPDF,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Text('Order PDF',style: TextStyle(color: Colors.white,fontSize: 15),),
      ),
      ElevatedButton(
        onPressed: generateProductsPDF,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Products PDF',style: TextStyle(color: Colors.white,fontSize: 15),),
      ),
    ],
  );
}