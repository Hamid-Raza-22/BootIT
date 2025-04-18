class SMStatusModel {

  final dynamic booker_id;
  final dynamic name;
  final dynamic designation;
  final dynamic attendanceStatus;
  final dynamic city;

  SMStatusModel({
    required this.booker_id,
    required this.name,
    required this.designation,
    required this.attendanceStatus,
    required this.city,
  });

  factory SMStatusModel.fromJson(Map<dynamic, dynamic> json) {
    return SMStatusModel(
      booker_id: json['user_id'],
      name: json['user_name'],
      designation: json['designation'],
      attendanceStatus: json['status'],
      city: json['city'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'user_id':booker_id,
      'user_name': name,
      'designation': designation,
      'status': attendanceStatus,
      'city': city,
    };
  }
}
