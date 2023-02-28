import 'package:cloud_firestore/cloud_firestore.dart';

class StoredDataModel {
  final String address;
  final String generatedNumber;
  final String ip;
  final String currentTime;
  final String imageUrl;

  const StoredDataModel( 
      {required this.address,
      required this.generatedNumber,
      required this.ip,
      required this.currentTime,
      required this.imageUrl});

  static StoredDataModel fromJson(Map<String,dynamic> json) {
    StoredDataModel storedDataModel = StoredDataModel(
        address: json["address"],
       generatedNumber: json["generatedNumber"],
        ip: json["ip"],
        currentTime: json["currentTime"],
        imageUrl: json["imageUrl"]);
    return storedDataModel;
  }
  static StoredDataModel fromsnapshot(DocumentSnapshot snap) {
    StoredDataModel storedDataModel = StoredDataModel(
        address: snap["address"],
        generatedNumber: snap["generatedNumber"],
        ip: snap["ip"],
        currentTime: snap["currentTime"],
        imageUrl: snap["imageUrl"]);
    return storedDataModel;
  }
}
