import 'dart:convert';
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
import 'package:http/http.dart' as http;
import 'category_meals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;

  // List of categories (Initially empty, will be populated from API)
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Provider.of<ApiService>(context, listen: false).fetchRandomMeals();
    _fetchCategories();  // Fetch categories from the API
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
    await prefs.remove('id');

    setState(() {
      _isLoggedIn = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // Fetch categories from API
  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = json.decode(response.body);
      final List<dynamic> categoryList = data['categories'];

      // Update the categories list state
      setState(() {
        categories = categoryList
            .map<String>((category) => category['strCategory'] as String) // Cast to String
            .toList();
      });
    } else {
      // Handle API error
      print('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Recipe Finder'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Open the drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
              debugPrintToken();
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Favorites'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            ListTile(
              title: const Text('Search'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
              },
            ),
            if (_isLoggedIn)
              ListTile(
                title: const Text('Logout'),
                onTap: _logout,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Horizontal ListView for categories
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: categories.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the Category Meals screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryMealsScreen(
                                  category: categories[index], // Passing selected category
                                ),
                              ),
                            );
                          },
                          child: Chip(
                            label: Text(categories[index]),
                            backgroundColor: Colors.blueAccent,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),
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
  String? userId = prefs.getString("_id");

  print("SharedPreferences Token: $sharedToken");
  print("SharedPreferences email: $emailToken");
  print("SharedPreferences id: $userId");

}



