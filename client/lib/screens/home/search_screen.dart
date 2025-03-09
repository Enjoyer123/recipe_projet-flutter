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
  
  void initState() {
    super.initState();
    // ล้างค่าการค้นหาเมื่อเปิดหน้าค้นหาใหม่
    _searchController.clear();
// ใช้ addPostFrameCallback เพื่อให้แน่ใจว่า context พร้อมก่อนเรียก provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApiService>(context, listen: false).clearsearch();
    });
    
  }
  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE3AFBC),
      appBar: AppBar(
        title: const Text('Search Recipes'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xFFEE4C74),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  filled:
                      true, // This enables the background color of the TextField
                  fillColor: const Color.fromARGB(
                      255, 255, 255, 255), // Change this to your desired color
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      apiService.fetchMealsFromRecipeDb(_searchController.text);
                    },
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: const Color(0xFFEE4C74), // Color of the underline when focused
                      width: 2.0, // Underline width when focused
                    ),
                  ),
                ),
              )),
          
          // Expanded(
          //   child: apiService.meals.isEmpty
          //       ? const Center(child: Text('Search for a recipe!'))
          //       : ListView.builder(
          //           itemCount: apiService.meals.length,
          //           itemBuilder: (context, index) {
          //             final meal = apiService.meals[index];
          //             return GestureDetector(
          //               onTap: () async {
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                       builder: (_) => DetailScreen(meal: meal)),
          //                 );
          //               },
          //               child: MealCard(meal: meal),
          //             );
          //           },
          //         ),
          // ),

          Expanded(
            child: apiService.meals.isEmpty
                ? const Center(child: Text('Search for a recipe!'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: apiService.meals.length,
                    itemBuilder: (context, index) {
                      final meal = apiService.meals[index];
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
