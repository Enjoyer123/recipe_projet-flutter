import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'detail_user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? sharedToken;

  bool _isLoggedIn = false;

  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
    _checkLoginStatus();
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
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this recipe?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancle",
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Delete",
                    style: TextStyle(color: Color(0xFFEE4C74))),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    sharedToken = prefs.getString('token');

    if (sharedToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ApiService>(context, listen: false)
            .fetchFavoritesFromMongoDb(sharedToken!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE3AFBC),
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: apiService.favorites.isEmpty
          ? const Center(
              child: Text('No favorites yet!',
                  style: TextStyle(fontSize: 18, color: Colors.black54)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              itemCount: apiService.favorites.length,
              itemBuilder: (context, index) {
                final meal = apiService.favorites[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: const Text(
                      'Tap to view details',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    // trailing: IconButton(
                    //   icon: const Icon(Icons.delete, color: Color(0xFFEE4C74)),
                    //   onPressed: () async {
                    //     await apiService.removeFavorite(meal);
                    //   },
                    // ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFEE4C74)),
                      onPressed: () async {
                        bool confirmDelete =
                            await _showDeleteConfirmationDialog(context);
                        if (confirmDelete) {
                          await apiService.removeFavorite(meal);
                        }
                      },
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DetailScreen(meal: meal)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
