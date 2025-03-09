import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/meal_card.dart';
import 'detail_screen.dart';
import '../../models/meal.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';

class CategoryMealsScreen extends StatefulWidget {
  final String category;

  const CategoryMealsScreen({super.key, required this.category});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryMealsScreenState createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  List<Meal> meals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMealsByCategory();
  }

  Future<void> _fetchMealsByCategory() async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        meals = (data['meals'] as List)
            .map((mealJson) => Meal.fromRecipeDbJson(mealJson))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE3AFBC),
      appBar: AppBar(
        title: Text('${widget.category} Meals'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFEE4C74)), // กำหนดสีที่ต้องการ
              ),
            )
          : meals.isEmpty
              ? const Center(child: Text('No meals found for this category'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return GestureDetector(
                      onTap: () async {
                        final mealDetails =
                            await apiService.fetchMealDetails(meals[index].id);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => DetailScreen(meal: mealDetails),
                        ));
                      },
                      child: MealCard(meal: meal),
                    );
                  },
                ),
    );
  }
}
