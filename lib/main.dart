import 'package:exampleapp/auth/auth_bloc.dart';
import 'package:exampleapp/auth/auth_state.dart';
import 'package:exampleapp/data_bloc/data_bloc.dart';
import 'package:exampleapp/firestore/firestore_service.dart';
import 'package:exampleapp/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'pages/dashboard_page.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<IpAddressBloc>(create: (context)=> IpAddressBloc()),
           BlocProvider<GetLocationAddressBloc>(create: (context)=> GetLocationAddressBloc()),
           BlocProvider<StoreAndGetImage>(create: (context)=> StoreAndGetImage()),
            BlocProvider<AuthBloc>(create: (context) => AuthBloc(),),
            BlocProvider<FirestoreService>(create: (context)=> FirestoreService()), 
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if(state is AuthLoggedInState){
                  return const DashboardPage();
                }
                return const LoginPage();
              }
            )
            ),
        );
      }
    );
  }
}


