import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exampleapp/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/data_model.dart';

class FirestoreService extends Cubit<bool>{
  FirestoreService() : super(false);

 void addFirebase(StoredDataModel storedDataModel)async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  String userId = pref.getString(Constants.userId) ?? "";
  final collectionReference = FirebaseFirestore.instance;
      final locationData = <String, dynamic>{
      'ip': storedDataModel.ip,
      "address": storedDataModel.address,
      'time': storedDataModel.currentTime,
      "generatedNumber" : storedDataModel.generatedNumber,
      "imageUrl" : storedDataModel.imageUrl
    };
    
    final DocumentReference documentReference = await collectionReference.collection(userId).add(locationData);
    
    bool isAdded = false;
    if (documentReference != null) {
      isAdded = true;  
    } else {
      isAdded = false;
    }
    emit(isAdded);
}

  
}
