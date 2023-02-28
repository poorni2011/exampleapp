import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IpAddressBloc extends Cubit<String> {
  IpAddressBloc() : super("");

  Future<void> getIPAddress() async {
    String ip = '';
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      ip = await getMobileIPAddress();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      ip = await getWifiIPAddress();
    }
    emit(ip);
  }

  Future<String> getMobileIPAddress() async {
    try {
      final ipAddress =
          (await NetworkInterface.list(type: InternetAddressType.IPv4))
              .first
              .addresses
              .first
              .address;
      return ipAddress;
    } catch (_) {
      return '';
    }
  }

  Future<String> getWifiIPAddress() async {
    try {
      final ipAddress = await NetworkInfo().getWifiIP();
      return ipAddress ?? '';
    } catch (_) {
      return '';
    }
  }
}

class GetLocationAddressBloc extends Cubit<String> {
  GetLocationAddressBloc() : super("");

  Future getLocationAddress() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position latlong = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latlong.latitude, latlong.longitude);
    Placemark place = placemarks[0];
    String address = '${place.name},${place.thoroughfare}, ${place.locality}';
    emit(address);
  }
}

class StoreAndGetImage extends Cubit<String> {
  StoreAndGetImage() : super("");

  Future storeAndGetImagePath(String randNum) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    ui.Image qrImage = await QrPainter(
      data: randNum,
      version: QrVersions.auto,
    ).toImage(200);
    ByteData? byteData =
        await qrImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child("images");
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);
    UploadTask uploadTask = referenceImageToUpload.putData(pngBytes);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageeUrl = await taskSnapshot.ref.getDownloadURL();
    emit(imageeUrl);
  }
}
