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

  List<String> categories = [];
  String _userName = '';
  @override
  void initState() {
    final apiService = Provider.of<ApiService>(context, listen: false);

    super.initState();
    _fetchUserName();
    _checkLoginStatus();
    apiService.fetchRandomMeals();
    _fetchCategories();
    debugPrintToken();
  }

  Future<void> _fetchUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('name');
    setState(() {
      _userName = userName ?? 'Guest';
    });
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

  Future<void> _fetchCategories() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categoryList = data['categories'];

      setState(() {
        categories = categoryList
            .map<String>((category) => category['strCategory'] as String)
            .toList();
      });
    } else {
      print('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFE3AFBC),
      appBar: AppBar(
        title: const Text('Recipe Finder'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()));
                debugPrintToken();
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFEE4C74),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hello, $_userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text('Favorites',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.black),
              title:
                  const Text('Search', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()));
              },
            ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.black),
                title:
                    const Text('Logout', style: TextStyle(color: Colors.black)),
                onTap: _logout,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: categories.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFEE4C74)), // กำหนดสีที่ต้องการ
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryMealsScreen(
                                  category: categories[index],
                                ),
                              ),
                            );
                          },
                          child: Chip(
                            label: Text(categories[index]),
                            backgroundColor: const Color(0xFFEE4C74),
                            labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Expanded(
            child: apiService.randomMeals.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFEE4C74)), // กำหนดสีที่ต้องการ
                    ),
                  )
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
  String? name = prefs.getString("name");
  print("SharedPreferences Token: $sharedToken");
  print("SharedPreferences email: $emailToken");
  print("SharedPreferences id: $userId");
  print("SharedPreferences name: $name");
}
