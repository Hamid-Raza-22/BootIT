class OrderMasterModel{
  String? orderMasterId;
  String? shopName;
  String? ownerName;
  String? phoneNumber;
  String? brand;
  String? total;
  String? creditLimit;
  String? requiredDelivery;

  OrderMasterModel({
    this.orderMasterId,
    this.shopName,
    this.ownerName,
    this.phoneNumber,
    this.brand,
    this.total,
    this.creditLimit,
    this.requiredDelivery,
  });
  factory OrderMasterModel.fromMap(Map<dynamic,dynamic> json){
    return OrderMasterModel(
      orderMasterId: json['orderMasterId'],
      shopName: json['shopName'],
      ownerName: json['ownerName'],
      phoneNumber: json['phoneNumber'],
      brand:json['brand'],
      total:json['total'],
      creditLimit:json['creditLimit'],
      requiredDelivery:json['requiredDelivery'],
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'orderMasterId':orderMasterId,
      'shopName':shopName,
      'ownerName':ownerName,
      'phoneNumber':phoneNumber,
      'brand':brand,
      'total':total,
      'creditLimit':creditLimit,
      'requiredDelivery':requiredDelivery,
    };
  }

}
