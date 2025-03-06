import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends ChangeNotifier {
  List<Meal> meals = [];
  List<Meal> randomMeals = [];
  List<String> _notes = [];

  List<String> get notes => _notes;

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
   

    _isFavoriteButtonDisabled = true;
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
    final userId = await getIdFromSession();

  if (userId == null) {
    throw Exception('No Id found in session');
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
      'area': meal.area,
      'instructions' : meal.instructions,
      'videoUrl': meal.videoUrl,
      'category': meal.category,
      'ingredients': meal.ingredients,
      'imageUrl': meal.image,
      'createdAt': DateTime.now().toIso8601String(),
      'email': email,
      'userId': userId
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
   
    final url = Uri.parse('http://localhost:5000/favorites/${meal.id}');

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

Future<String?> getIdFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('_id');
  }


Future<void> addNoteToMeal(String mealId, String note) async {
  final userId = await getIdFromSession();

  if (userId == null) {
    throw Exception('No Id found in session');
  }

  final url = Uri.parse('http://localhost:5000/favorites/$mealId/$userId'); // ใช้ทั้ง mealId และ userId

  final body = json.encode({
    'note': note,  // ส่งโน้ตไปเพิ่มใน array
  });

  // เปลี่ยนจาก PUT เป็น POST
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );
  

  if (response.statusCode == 200) {
    notifyListeners();
  } else {
    print("Error: ${response.body}");
    throw Exception('Failed to add note');
  }
    notifyListeners(); 
}


  Future<void> fetchNotesFromServer(String mealId) async {
    final userId = await getIdFromSession();

  if (userId == null) {
    throw Exception('No Id found in session');
  }
  final url = Uri.parse('http://localhost:5000/favorites/$mealId/$userId'); // ใช้ทั้ง mealId และ userId
  final response = await http.get(url);
 notifyListeners();
  if (response.statusCode == 200) {

   
    
  } else {
    throw Exception('Failed to fetch notes');
  }
}

 // Function to delete a note
Future<void> deleteNoteFromMeal(String mealId, String userId, int noteIndex) async {
  final response = await http.delete(
    Uri.parse('http://localhost:5000/favorites/$mealId/$userId/note/$noteIndex'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete note');
  }
}

// Function to update a note
Future<void> updateNoteForMeal(String mealId, int noteIndex, String newNote) async {
 
  final userId = await getIdFromSession();
  final response = await http.put(
    Uri.parse('http://localhost:5000/favorites/$mealId/$userId/note/$noteIndex'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: json.encode({'note': newNote}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update note');
  }
}



Future<Meal> fetchMealDetails(String idMeal) async {
  final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal');
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // ตรวจสอบว่า 'meals' อยู่ใน response และมีข้อมูลหรือไม่
    if (data['meals'] != null && data['meals'].isNotEmpty) {
      // แปลงข้อมูลจาก API เป็น Meal object
      final mealData = data['meals'][0];

      // ใช้ Meal.fromRecipeDbJson เพื่อแปลงข้อมูล
      final meal = Meal.fromRecipeDbJson(mealData);

      return meal;
    } else {
      throw Exception('No meals found for this id');
    }
  } else {
    throw Exception('Failed to load meal details');
  }
}



}

