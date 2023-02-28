import 'package:exampleapp/auth/auth_bloc.dart';
import 'package:exampleapp/auth/auth_state.dart';
import 'package:exampleapp/data_bloc/data_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import '../constant.dart';
import '../firestore/firestore_service.dart';
import 'login_page.dart';
import '../model/data_model.dart';
import 'last_login_page.dart';
import 'dart:math';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  var gNumber = 0;
  String address = "";
  String ipAddress = "";
  String imageUrl = "";
  
  bool isButtonLoading = false;
  bool isLoading = false;

  getRandomNumber() {
    gNumber = Random().nextInt(900000) + 10000;
    setState(() {
      gNumber = gNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    getRandomNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          Positioned(
            top: 4.h,
            right: 6,
            child:
                BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
              if (state is AuthLoggedOutState) {
                Navigator.pushAndRemoveUntil(context, 
                MaterialPageRoute(builder: (context)=> const LoginPage()), (route) => false);
              }
            }, builder: (context, state) {
              return TextButton(
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).logout();
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }),
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              color: Colors.black,
            ),
            margin: EdgeInsets.only(top: 75.sp),
          ),
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                margin: EdgeInsets.only(
                  top: 60.sp,
                ),
                child: const Text(
                  "PLUGIN",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
              SizedBox(
                height: 9.h,
              ),
              Center(
                child: QrImage(
                  size: 130.sp,
                  backgroundColor: Colors.white,
                  data: gNumber.toString(),
                ),
              ),
              SizedBox(
                height: 7.h,
              ),
              const Text(
                "Generated Number",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                gNumber.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LastLoginPage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white)),
                  padding:
                      EdgeInsets.symmetric(vertical: 8.sp, horizontal: 27.w),
                  child: const Text(
                    "Last login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              ElevatedButton(
                  onPressed: (){
                    saveData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 28.w, vertical: 1.6.h),
                    child: isButtonLoading == true
                        ? SizedBox(
                            height: 2.3.h,
                            width: 4.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : isLoading == true
                            ? SizedBox(
                                height: 2.3.h,
                                width: 4.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "SAVE",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                  )),
              SizedBox(
                height: 3.h,
              )
            ],
          )
        ],
      ),
    );
  }

  saveData() {
    String formattedDate =
      DateFormat("hh:mm a, EEE d MMM").format(DateTime.now());
    final addressData = BlocProvider.of<GetLocationAddressBloc>(context);
    addressData.getLocationAddress();
    address = addressData.state;
    final ipAddressData = BlocProvider.of<IpAddressBloc>(context);
    ipAddressData.getIPAddress();
    ipAddress = ipAddressData.state;
    final imageurlData = BlocProvider.of<StoreAndGetImage>(context);
    imageurlData.storeAndGetImagePath(gNumber.toString());
    imageUrl = imageurlData.state;

    if (address.isEmpty && ipAddress.isEmpty && imageUrl.isEmpty) {
      setState(() {
        isButtonLoading = true;
      });
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Fetching Details"),
              content: const Text("Please Try again"),
              actions: [
                TextButton(
                  child: const Text("Try Again"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardPage()), (route) => false);
                   
                  },
                )
              ],
            );
          });
    } else if (address.isNotEmpty &&
        ipAddress.isNotEmpty &&
        imageUrl.isNotEmpty) {
      setState(() {
        isButtonLoading = false;
        isLoading = true;
      });

      final addFirebase = BlocProvider.of<FirestoreService>(context);
      addFirebase.addFirebase(StoredDataModel(
          generatedNumber: gNumber.toString(),
          address: address,
          ip: ipAddress,
          currentTime: formattedDate,
          imageUrl: imageUrl));

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
        getRandomNumber();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text("Data Added Successfully")));
      });
    }
  }
}
