import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booking_app/Screens/SM/SMOrderDetails/sm_bookers_booking_details_screen.dart';
import 'package:order_booking_app/Services/FirebaseServices/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../Databases/util.dart';
import '../../../Models/Bookers_RSM_SM_NSM_Models/nsm_bookers_order_model.dart';



class SmBookersOrderDetailsScreen extends StatefulWidget {
  const SmBookersOrderDetailsScreen({super.key});

  @override
  _NSM_SM_StatusState createState() => _NSM_SM_StatusState();
}

class _NSM_SM_StatusState extends State<SmBookersOrderDetailsScreen> {
  List<NsmBookersOrderModel> _allBookers = [];
  List<NsmBookersOrderModel> _filteredBookers = [];
  final List<NsmBookersOrderModel> _displayedBookers = [];
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    bool isConnected = await isNetworkAvailable();
    if (isConnected) {
      bool newDataFetched = await _fetchAndSaveData();
      if (newDataFetched) {
        await _loadBookersData();
        _filteredBookers = _allBookers;
        _addBookersToList(_filteredBookers);
      } else {
        await _loadBookersData();
        _filteredBookers = _allBookers;
        _addBookersToList(_filteredBookers);
      }
    } else {
      // Load cached data
      await _loadBookersData();
      _filteredBookers = _allBookers;
      _addBookersToList(_filteredBookers);

      // Show last sync time
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? lastSyncTime = prefs.getString('last_SM_RSM_sync_time');
      if (lastSyncTime != null) {
        DateTime syncDateTime = DateTime.parse(lastSyncTime);
        String formattedTime = "${syncDateTime.toLocal()}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Last sync: $formattedTime')),
        );
      }
    }
  }

   Future<bool> _fetchAndSaveData() async {
    await Config.fetchLatestConfig();
    //final response = await http.get(
       // Uri.parse(
    final url = '${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlSmUserOrder}$user_id';
    debugPrint(url);
    // final url = 'https://cloud.metaxperts.net:8443/erp/test1/smuserorders/get/$user_id';
    final response = await http.get(
        Uri.parse('${Config.getApiUrlServerIP}${Config.getApiUrlERPCompanyName}${Config.getApiUrlSmUserOrder}$user_id'
        ));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['items'];
      List<NsmBookersOrderModel> fetchedBookers = data.map<NsmBookersOrderModel>((json) => NsmBookersOrderModel.fromJson(json)).toList();

      // Compare with existing data to check if new data is fetched
      bool isNewData = _hasNewData(fetchedBookers, _allBookers);

      if (isNewData) {
        _allBookers = fetchedBookers;
        await _saveBookersData();

        // Save the last sync timestamp
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_NSM_SM_sync_time', DateTime.now().toIso8601String());
      }

      return isNewData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  bool _hasNewData(List<NsmBookersOrderModel> newData, List<NsmBookersOrderModel> oldData) {
    if (newData.length != oldData.length) return true;
    for (int i = 0; i < newData.length; i++) {
      if (newData[i].toJson() != oldData[i].toJson()) return true;
    }
    return false;
  }

  Future<String?> _getLastSyncTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastSyncTime = prefs.getString('last_NSM_SM_sync_time');
    if (lastSyncTime != null) {
      DateTime syncDateTime = DateTime.parse(lastSyncTime);
      return "${syncDateTime.toLocal()}";
    }
    return null;
  }


  Future<void> _saveBookersData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bookersJson = jsonEncode(_allBookers.map((b) => b.toJson()).toList());
    prefs.setString('NSM_SM_data', bookersJson);
  }

  Future<void> _loadBookersData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bookersJson = prefs.getString('NSM_SM_data');
    if (bookersJson != null) {
      List<dynamic> jsonList = jsonDecode(bookersJson);
      _allBookers = jsonList.map((json) => NsmBookersOrderModel.fromJson(json)).toList();
    }
  }



  void _addBookersToList(List<NsmBookersOrderModel> bookers) async {
    for (int i = 0; i < bookers.length; i++) {
      if (!_displayedBookers.contains(bookers[i])) {
        _displayedBookers.add(bookers[i]);
        _listKey.currentState?.insertItem(_displayedBookers.indexOf(bookers[i]), duration: const Duration(seconds: 1));
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _removeBookersFromList() async {
    for (int i = _displayedBookers.length - 1; i >= 0; i--) {
      final removedBooker = _displayedBookers.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
            (context, animation) => _buildBookerCard(removedBooker, animation),
        duration: const Duration(milliseconds: 300),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _filterBookers() {
    final nameFilter = _nameController.text.toLowerCase();
    _filteredBookers = _allBookers.where((booker) {
      final matchesName = booker.name.toLowerCase().contains(nameFilter);
      return matchesName ;
    }).toList();
    _removeBookersFromList();
    _addBookersToList(_filteredBookers);
  }


  void showProfessionalDialog(BuildContext context, String message, IconData icon, Color backgroundColor, {String? actionText, VoidCallback? onActionPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundColor.withOpacity(0.7), backgroundColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 36),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionText != null && onActionPressed != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      elevation: 1,
                    ),
                    onPressed: onActionPressed,
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _handleRefresh() async {
    try {
      bool isConnected = await isNetworkAvailable();
      if (isConnected) {
        const timeoutDuration = Duration(seconds: 20);
        Future<void> loadDataFuture = _loadData();

        await loadDataFuture.timeout(timeoutDuration, onTimeout: () {
          throw TimeoutException('Data loading took too long');
        });

        setState(() {
          _filteredBookers = _allBookers;
          _removeBookersFromList();
          _addBookersToList(_filteredBookers);
        });

        showProfessionalDialog(
          context,
          'Data refreshed successfully!',
          Icons.check_circle_outline,
          Colors.green[600]!,
        );
      } else {
        showProfessionalDialog(
          context,
          'No internet connection. Please check your connection and try again.',
          Icons.signal_wifi_off,
          Colors.red[600]!,
          actionText: 'Retry',
          onActionPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            _handleRefresh(); // Retry refreshing data
          },
        );
      }
    } catch (e) {
      // Handle timeout and other errors
      if (e is TimeoutException) {
        showProfessionalDialog(
          context,
          'Data refresh timed out. Please try again later.',
          Icons.timer_off,
          Colors.orange[600]!,
          actionText: 'Retry',
          onActionPressed: () {
            Navigator.of(context).pop();
            _handleRefresh();
          },
        );
      } else {
        // Handle any other errors
        if (kDebugMode) {
          print('Error during refresh: $e');
        }
        showProfessionalDialog(
          context,
          'Failed to refresh data. Please try again later.',
          Icons.error_outline,
          Colors.orange[600]!,
          actionText: 'Retry',
          onActionPressed: () {
            Navigator.of(context).pop();
            _handleRefresh();
          },
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child:  Column(
          children: [
            Column(
              children: [
                _buildTextField('Search by Booker Name', _nameController, false, false),
              ],
            ),

            FutureBuilder<String?>(
              future: _getLastSyncTime(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData && snapshot.data != null) {
                  DateTime lastSyncDateTime = DateTime.parse(snapshot.data!);
                  String formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(lastSyncDateTime);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Last Sync: ',
                              style: TextStyle(fontSize: 10.0),
                            ),
                            const SizedBox(height: 4.0), // Add gap between Last Sync and the date
                            Text(
                              formattedTime,
                              style: const TextStyle( fontSize: 10.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // No data to display
                }
              },
            ),

            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: _displayedBookers.length,
                itemBuilder: (context, index, animation) {
                  final booker = _displayedBookers[index];
                  return _buildBookerCard(booker, animation);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isDate, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(
              isDate ? Icons.calendar_today : Icons.search,
              color: Colors.green,
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4), fontSize: 13),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green, width: 0.1),
              borderRadius: BorderRadius.circular(1.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          ),
          keyboardType: isDate ? TextInputType.datetime : TextInputType.text,
          readOnly: isReadOnly,
          onChanged: (value) {
            _filterBookers();
          },
        ),
      ),
    );
  }

  Widget _buildBookerCard(NsmBookersOrderModel booker, Animation<double> animation) {
    Color statusColor;
    String statusText;

    // Determine the color and text based on the attendance status
    // switch (booker.attendanceStatus) {
    //   case 'clock_in':
    //     statusColor = Colors.green;
    //     statusText = 'Clocked In';
    //     break;
    //   case 'clock_out':
    //     statusColor = Colors.red;
    //     statusText = 'Clocked Out';
    //     break;
    //   default:
    //     statusColor = Colors.grey;
    //     statusText = 'Unknown';
    // }

    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SmBookersBookingDetailsScreen(booker: booker),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.all(1.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: Image.asset(
                      'assets/icons/avatar3.png', // Path to your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booker.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Text(
                              booker.booker_id,
                              style: const TextStyle(fontSize: 11, color: Colors.black),
                            ),
                            const Spacer(),
                            // Container(
                            //   padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                            //   decoration: BoxDecoration(
                            //     color: statusColor.withOpacity(0.2),
                            //     borderRadius: BorderRadius.circular(3.0),
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Text(
                            //         statusText,
                            //         style: TextStyle(fontSize: 9, color: statusColor), // Status color
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.work, size: 11.0, color: Colors.green),
                          const SizedBox(width: 1.0),
                          Expanded(
                            child: Text(
                              ' ${booker.designation}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      // if (booker.designation == 'SO') ...[
                      //   const SizedBox(height: 1.0),
                      //   // Row(
                      //   //   children: [
                      //   //     const Icon(Icons.location_city, size: 11.0, color: Colors.green),
                      //   //     const SizedBox(width: 4.0),
                      //   //
                      //   //   ],
                      //   // ),
                      // ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


