class Meal {
  final String id;
  final String name;
  final String image;
  final String instructions;
  final String area;
  final String videoUrl;
  final String category;
  final List<String> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.image,
    required this.instructions,
    required this.area,
    required this.videoUrl,
    required this.category,
    required this.ingredients,
  });

  factory Meal.fromRecipeDbJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'] ?? '';
      String measure = json['strMeasure$i'] ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add("$ingredient - $measure");
      }
    }

    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      image: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      area: json['strArea'] ?? 'ไม่ทราบ',
      videoUrl: json['strYoutube'] != null
          ? json['strYoutube'].replaceFirst("watch?v=", "embed/")
          : '',
      ingredients: ingredients,
      category: json['strCategory'] ?? '',
    );
  }

  factory Meal.fromMongoDbJson(Map<String, dynamic> json) {
    return Meal(
      id: json['_id'] ?? json['idMeal'] ?? '',
      name: json['title'] ?? json['strMeal'] ?? '',
      image: json['imageUrl'] ?? json['strMealThumb'] ?? '',
      instructions: json['instructions'] ?? json['strInstructions'] ?? '',
      area: json['area'] ?? json['strArea'] ?? 'ไม่ทราบ',
      videoUrl:json['videoUrl'] != null && (json['videoUrl'] as String).isNotEmpty
              ? json['videoUrl'].replaceFirst("watch?v=", "embed/")
              : json['strYoutube'] != null && (json['strYoutube'] as String).isNotEmpty
              ? (json['strYoutube'] as String).replaceFirst("watch?v=", "embed/")
              : '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      category: json['category'] ?? json['strCategory'] ?? '',
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'idMeal': id,
  //     'strMeal': name,
  //     'strMealThumb': image,
  //     'strInstructions': instructions,
  //   };
  // }
}
