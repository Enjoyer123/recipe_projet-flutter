import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends ChangeNotifier {
  List<Meal> meals = [];
  List<Meal> randomMeals = [];

  List<Meal> _favorites = [];
  bool _isFavoriteButtonDisabled = false;

  List<Meal> get favorites => _favorites;
  bool get isFavoriteButtonDisabled => _isFavoriteButtonDisabled;

  Future<void> fetchRandomMeals() async {
    randomMeals.clear();
    for (int i = 0; i < 10; i++) {
      final url =
          Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          randomMeals.add(Meal.fromRecipeDbJson(data['meals'][0]));
        }
      }
    }
    notifyListeners();
  }

  Future<void> fetchMealsFromRecipeDb(String query) async {
    final url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      meals = (data['meals'] as List?)
              ?.map((meal) => Meal.fromRecipeDbJson(meal))
              .toList() ??
          [];
      notifyListeners();
    } else {
      throw Exception('Failed to load meals from RecipeDB');
    }
  }

  Future<String?> getEmailFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> fetchFavoritesFromMongoDb(String token) async {
    final userEmail = await getEmailFromSession();

    if (userEmail == null) {
      throw Exception('No email found in session');
    }

    final url = Uri.parse('http://localhost:5000/favorites?email=$userEmail');
    // final response = await http.get(url);
final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', 
    },
  );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _favorites = (data['data'] as List?)
              ?.map((meal) => Meal.fromMongoDbJson(meal))
              .toList() ??
          [];
      notifyListeners();
    } else {
      throw Exception('Failed to load favorite meals from MongoDB');
    }
  }

  Future<bool> isFavoriteAlreadyInDb(String recipeId) async {
    final url = Uri.parse('http://localhost:5000/favorites/$recipeId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] != null;
    } else {
      throw Exception('Failed to check favorite in MongoDB');
    }
  }

  Future<void> addFavoriteToMongoDb(Meal meal, BuildContext context) async {
    print("kyu");
    print(_isFavoriteButtonDisabled);

    _isFavoriteButtonDisabled = true;
    print(_isFavoriteButtonDisabled);
    notifyListeners();

    // ---------------

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User is not logged in. Please login first.'),
          duration: Duration(seconds: 2),
        ),
      );
      _isFavoriteButtonDisabled = false;
      notifyListeners();
      return;
    }
    // ---------------

    final checkUrl = Uri.parse('http://localhost:5000/favorites/${meal.id}');
    final checkResponse = await http.get(checkUrl);

    if (checkResponse.statusCode == 200) {
      _isFavoriteButtonDisabled = false; 
    }

    final url = Uri.parse('http://localhost:5000/favorites/');
    final body = json.encode({
      'recipeId': meal.id,
      'title': meal.name,
      'description': meal.instructions,
      'imageUrl': meal.image,
      'createdAt': DateTime.now().toIso8601String(),
      'email': email,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      _favorites.add(meal);
      _isFavoriteButtonDisabled = false;
      notifyListeners();
    } else {
      _isFavoriteButtonDisabled = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to favorites. Please try again later.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> toggleFavorite(Meal meal, BuildContext context) async {
    final isFavorite = _favorites.contains(meal);
    if (isFavorite) {
      // await removeFavorite(meal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to favorites. Please try again later.'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      await addFavoriteToMongoDb(meal, context);
    }

    _isFavoriteButtonDisabled = false;
    notifyListeners();
  }

 
  Future<void> removeFavorite(Meal meal) async {
    _isFavoriteButtonDisabled = true; 
    notifyListeners();

    final url = Uri.parse(
        'http://localhost:5000/favorites/${meal.id}'); 
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      _favorites.remove(meal);
      _isFavoriteButtonDisabled = false; 
      notifyListeners();
    } else {
      _isFavoriteButtonDisabled = false; 
      throw Exception('Failed to remove favorite meal from MongoDB');
    }
  }
}
