import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import '../constant.dart';
import 'login_page.dart';

class LastLoginPage extends StatefulWidget {
  const LastLoginPage({super.key});

  @override
  State<LastLoginPage> createState() => _LastLoginPageState();
}

class _LastLoginPageState extends State<LastLoginPage> {
  final ref = FirebaseFirestore.instance;
  String? userId;
  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(Constants.userId);
    setState(() {
      userId = id;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserId();
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
                // Navigator.pushReplacement(context,
                //     MaterialPageRoute(builder: (context) => const LoginPage()));
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
                  "Last Login",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
              StreamBuilder(
                  stream: ref.collection(userId!).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      if (snapshot.data!.docs.reversed.isNotEmpty) {
                        return 
                        Flexible(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, i) {
                                return Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 4.w, vertical: 1.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.data!.docs[i]
                                                    .data()["time"],
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                snapshot.data!.docs[i]
                                                    .data()["ip"],
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                height: 0.6.h,
                                              ),
                                              Text(
                                                snapshot.data!.docs[i]
                                                    .data()["address"],
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      right: 5.w,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.all(7),
                                        child: Image.network(
                                          snapshot.data!.docs[i]
                                              .data()["imageUrl"],
                                          height: 10.h,
                                          width: 10.h,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }),
                        );
                      } else {
                        return Center(
                            child: Padding(
                          padding: EdgeInsets.only(top: 37.h),
                          child: const Text(
                            "No data found",
                            style: TextStyle(color: Colors.white),
                          ),
                        ));
                      }
                    }
                    return Center(
                        child: Padding(
                      padding: EdgeInsets.only(top: 37.h),
                      child: const CircularProgressIndicator(),
                    ));
                  })
            ],
          ),
        ],
      ),
    );
  }
}
