import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../widgets/meal_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    apiService.fetchMealsFromRecipeDb(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: apiService.meals.isEmpty
                ? const Center(child: Text('Search for a recipe!'))
                : ListView.builder(
                    itemCount: apiService.meals.length,
                    itemBuilder: (context, index) {
                      final meal = apiService.meals[index];
                      return GestureDetector(
                        onTap: () async {
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
