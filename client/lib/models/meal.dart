class Meal {
  final String id;
  final String name;
  final String image;
  final String instructions;

  Meal({
    required this.id,
    required this.name,
    required this.image,
    required this.instructions,
  });

  factory Meal.fromRecipeDbJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      image: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
    );
  }

  factory Meal.fromMongoDbJson(Map<String, dynamic> json) {
    return Meal(
      id: json['_id'] ?? '',  
      name: json['title'] ?? '',  
      image: json['imageUrl'] ?? '',  
      instructions: json['description'] ?? '',  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strMealThumb': image,
      'strInstructions': instructions,
    };
  }
}
