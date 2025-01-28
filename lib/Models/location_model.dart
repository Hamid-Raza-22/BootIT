
import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

class LocationModel {
  dynamic? location_id;
  int posted;
  String? file_name;
  String? user_id;
  Uint8List? body;
  dynamic? booker_name;
  dynamic? total_distance;
  DateTime? location_date;
  DateTime? location_time;


  LocationModel({
    this.location_id,
    this.posted = 0,
    this.file_name,
    this.user_id,
    this.body,
    this.booker_name,
    this.location_date,
    this.location_time,
    this.total_distance
  });

  factory LocationModel.fromMap(Map<dynamic, dynamic> json) {

    return LocationModel(
      location_id: json['location_id'],
      posted: json['posted'] ?? 0,
      file_name: json['file_name'],
      user_id: json['user_id'],
      booker_name: json['booker_name'],
      total_distance: json['total_distance'],
      location_date: DateTime.now(),
      // Always set live date
      location_time: DateTime.now(),
      
      body: json['body'] != null && json['body'].toString().isNotEmpty
          ? Uint8List.fromList(base64Decode(json['body'].toString()))
          : null,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location_id': location_id,
      'posted': posted,
      'file_name': file_name,
      'user_id': user_id,
      'booker_name':booker_name,
      'location_date': DateFormat('dd-MMM-yyyy').format(location_date ?? DateTime.now()), // Always set live date
      'location_time': DateFormat('HH:mm:ss').format(location_time ?? DateTime.now()), // Always set live time
      'total_distance': total_distance,
      'body':  body != null ? base64Encode(body!) : null,
    };
  }
}