
// ignore: unused_import
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ReturnFormDetailsModel{
  String? return_details_id;
  String? item;
  String? quantity;
  String? reason;
  String? user_id;
  String? return_master_id;
  DateTime? return_details_date;
  DateTime? return_details_time;
  int posted;

  ReturnFormDetailsModel({
    this.return_details_id,
    this.item,
    this.user_id,
    this.quantity,
    this.reason,
    this.return_master_id,
    this.return_details_date,
    this.return_details_time,
    this.posted = 0,

  });

  factory ReturnFormDetailsModel.fromMap(Map<dynamic,dynamic> json){
    return ReturnFormDetailsModel(
      return_details_id: json['return_details_id'],
      item: json['item'],
      user_id: json['user_id'],
      quantity: json['quantity'],
      reason: json['reason'],
      return_master_id: json['return_master_id'],
      return_details_date: DateTime.now(),
      // Always set live date
      return_details_time: DateTime.now(),
      // Always set live time
      posted: json['posted'] ?? 0,

    );
  }

  Map<String, dynamic> toMap(){
    return{
      'return_details_id':return_details_id,
      'item':item,
      'user_id':user_id,
      'quantity':quantity,
      'reason':reason,
      'return_master_id':return_master_id,
      'return_details_date': DateFormat('dd-MMM-yyyy')
          .format(return_details_date ?? DateTime.now()), // Always set live date
      'return_details_time': DateFormat('HH:mm:ss')
          .format(return_details_time ?? DateTime.now()), // Always set live time
      'posted': posted,
    };
  }
}
