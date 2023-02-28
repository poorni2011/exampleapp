import 'package:exampleapp/auth/auth_state.dart';
import 'package:exampleapp/constant.dart';
import 'package:exampleapp/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../auth/auth_bloc.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mobile = TextEditingController();
  TextEditingController otp = TextEditingController();
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kPrimaryColor,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)),
                color: Colors.black,
              ),
              margin: EdgeInsets.only(top: 84.sp),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    margin: EdgeInsets.only(top: 70.sp, left: 109.sp),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 6.w, top: 90.sp, bottom: 10.sp),
                    child: const Text(
                      "Phone Number",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                  BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: SizedBox(
                            height: 7.h,
                            child: TextFormField(
                              controller: mobile,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              cursorWidth: 1,
                              decoration: InputDecoration(
                                  suffixIcon: TextButton(
                                    onPressed: () {
                                      String phoneNo = "+91${mobile.text}";
                                      BlocProvider.of<AuthBloc>(context)
                                          .sendOtp(phoneNo, context);
                                    },
                                    child: state is AuthSendOtpLoadingState
                                        ? SizedBox(
                                            height: 2.h,
                                            width: 4.w,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            "Send OTP",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: kPrimaryColor,
                                      )),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  filled: true,
                                  fillColor: kPrimaryColor),
                            ),
                          ),
                        );
                      }),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 6.w, top: 24.sp, bottom: 10.sp),
                    child: const Text(
                      "OTP",
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: SizedBox(
                      height: 7.h,
                      child: TextFormField(
                        controller: otp,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        cursorWidth: 1,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: kPrimaryColor,
                                )),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            fillColor: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
                    if (state is AuthLoggedInState) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashboardPage()));
                    }
                  }, builder: (context, state) {
                    if (state is AuthErrorState) {
                      WidgetsBinding.instance.addPostFrameCallback((_) =>
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(state.error),
                            duration: const Duration(milliseconds: 2000),
                          )));
                    }
                    return Center(
                      child: ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<AuthBloc>(context)
                                .verifyOtp(otp.text);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 28.w, vertical: 1.8.h),
                            child: state is AuthVerifyOtpLoadingState
                                ? SizedBox(
                                    height: 2.h,
                                    width: 4.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          )),
                    );
                  }),
                ],
              ),
            )
          ],
        ));
  }
}
