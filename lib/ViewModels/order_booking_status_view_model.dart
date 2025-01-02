import 'package:get/get.dart';
import '../Models/order_status_models.dart';
import '../Repositories/order_booking_status_repository.dart';

class OrderBookingStatusViewModel extends GetxController {
  // Observables
  var orders = <OrderBookingStatusModel>[].obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var shopName = ''.obs;
  var orderId = ''.obs;
  var status = ''.obs;
  var filteredRows = <OrderBookingStatusModel>[].obs;

  // Instance of the repository
  final OrderBookingStatusRepository _orderRepository = OrderBookingStatusRepository();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // Fetch orders from the repository
  Future<void> fetchOrders() async {
    try {
      List<OrderBookingStatusModel> fetchedOrders = await _orderRepository.safeFetchOrders();
      orders.value = fetchedOrders;
      filteredRows.value = fetchedOrders;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders: $e');
    }
  }

  // Update date range
  void updateDateRange(String start, String end) {
    startDate.value = start;
    endDate.value = end;
  }

  // Clear filters
  void clearFilters() {
    shopName.value = '';
    orderId.value = '';
    status.value = '';
    startDate.value = '';
    endDate.value = '';
  }

  // Filter data based on query
  void filterData(String query) {
    final lowerCaseQuery = query.toLowerCase();
    filteredRows.value = orders.where((order) {
      return order.shop.toLowerCase().contains(lowerCaseQuery) ||
          order.date.toLowerCase().contains(lowerCaseQuery) ||
          order.status.toLowerCase().contains(lowerCaseQuery) ||
          order.orderNo.toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  // Convert filtered rows to a list of maps
  List<Map<String, dynamic>> get filteredRowsAsMapList {
    return filteredRows.map((order) {
      return {
        'Order No': order.orderNo,
        'Date': order.date,
        'Shop': order.shop,
        'Status': order.status,
        'Amount': order.amount
      };
    }).toList();
  }

  // Handle button actions (e.g., Order PDF, Products PDF)
  void handleButtonAction(String action) {
    Get.snackbar('Action', '$action pressed!');
  }
}
