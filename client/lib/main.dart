import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const RecipeFinderApp());
}

class RecipeFinderApp extends StatelessWidget {
  const RecipeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recipe Finder',
        theme: ThemeData(primarySwatch: Colors.pink),
        // home: const HomeScreen(),
        home: const LoginScreen(),
      ),
    );
  }
}
