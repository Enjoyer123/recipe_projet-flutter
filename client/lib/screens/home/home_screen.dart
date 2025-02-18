import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'search_screen.dart';
import '../../widgets/meal_card.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Provider.of<ApiService>(context, listen: false).fetchRandomMeals();
  }

  Future<void> _checkLoginStatus() async {
    const storage = FlutterSecureStorage();
    String? secureToken = await storage.read(key: 'token');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sharedToken = prefs.getString('token');
    String? emailToken = prefs.getString('email');

    if (secureToken != null || sharedToken != null || emailToken != null) {
      setState(() {
        _isLoggedIn = true;
      });
    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await storage.delete(key: 'token');
    await prefs.remove('token');
    await prefs.remove('email');

    setState(() {
      _isLoggedIn = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Finder'),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              debugPrintToken();
              print("kuy");
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Random Recipes 🍽',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: apiService.randomMeals.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: apiService.randomMeals.length,
                    itemBuilder: (context, index) {
                      final meal = apiService.randomMeals[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailScreen(meal: meal)),
                          );
                        },
                        child: MealCard(meal: meal),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void debugPrintToken() async {
  const storage = FlutterSecureStorage();
  String? secureToken = await storage.read(key: 'token');
  print("Secure Storage Token: $secureToken");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sharedToken = prefs.getString('token');
  String? emailToken = prefs.getString('email');
  print("SharedPreferences Token: $sharedToken");
  print("SharedPreferences email: $emailToken");
}
