import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal.dart';
import '../../services/api_service.dart';
import 'favorites_screen.dart';

class DetailScreen extends StatelessWidget {
  final Meal meal;

  const DetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(meal.image),
            const SizedBox(height: 10),
            Text(meal.instructions, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: apiService.isFavoriteButtonDisabled
                  ? null
                  : () async {
                      await apiService.toggleFavorite(meal, context);
                      // print(apiService.isFavoriteButtonDisabled);
                    },
              child: Text(apiService.favorites.contains(meal)
                  ? 'Added to Favorites'
                  : 'Add to Favorites'),
            )
          ],
        ),
      ),
    );
  }
}
