import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../widgets/meal_card.dart';
import 'detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? sharedToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    sharedToken = prefs.getString('token');
    print(sharedToken);
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
      appBar: AppBar(title: const Text('Favorites')),
      body: apiService.favorites.isEmpty
          ? const Center(child: Text('No favorites yet!'))
          : ListView.builder(
              itemCount: apiService.favorites.length,
              itemBuilder: (context, index) {
                final meal = apiService.favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        meal.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await apiService.removeFavorite(meal);
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
