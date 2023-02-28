import 'package:exampleapp/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class AuthBloc extends Cubit<AuthState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  AuthBloc() : super(AuthInitialState()) {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      emit(AuthLoggedInState(currentUser));
    } else {
      emit(AuthLoggedOutState());
    }
  }

  String? _verificationCode;

  void sendOtp(String phoneNo, BuildContext context) async {
    emit(AuthSendOtpLoadingState());
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (phoneAuthCredential) {
          signInWithPhone(phoneAuthCredential);
        },
        verificationFailed: (exception) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text(exception.toString())));
          emit(AuthErrorState(exception.message.toString()));
        },
        codeSent: (verificationCode, forceResendingToken) {
          _verificationCode = verificationCode;

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text("OTP sent Successfully")));
          emit(AuthCodeSentState());
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationCode = verificationId;
        });
  }

  void verifyOtp(String otp) async {
    emit(AuthVerifyOtpLoadingState());
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationCode!, smsCode: otp);
    signInWithPhone(credential);
  }

  void signInWithPhone(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final user = auth.currentUser;
        final uid = user!.uid;
        prefs.setString(Constants.userId, uid);
        emit(AuthLoggedInState(userCredential.user!));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void logout() async {
    await auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    emit(AuthLoggedOutState());
  }
}
