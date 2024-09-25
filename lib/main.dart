import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/asset/asset_bloc.dart'; // Correct import path for AssetBloc
import 'screens/login_screen.dart'; // Import your Login Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AssetBloc(), // Provide AssetBloc at the root level
      child: MaterialApp(
        title: 'Asset Token App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(), // Set the initial screen to the Login Screen
      ),
    );
  }
}
