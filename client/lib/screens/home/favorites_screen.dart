// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/api_service.dart';
// import 'detail_user_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class FavoritesScreen extends StatefulWidget {
//   const FavoritesScreen({super.key});

//   @override
//   _FavoritesScreenState createState() => _FavoritesScreenState();
// }

// class _FavoritesScreenState extends State<FavoritesScreen> {
//   String? sharedToken;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     sharedToken = prefs.getString('token');

//     if (sharedToken != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Provider.of<ApiService>(context, listen: false)
//             .fetchFavoritesFromMongoDb(sharedToken!);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final apiService = Provider.of<ApiService>(context);

//     return Scaffold(
//       backgroundColor: const Color(0xFFE3AFBC),
//       appBar: AppBar(
//         title: const Text('Favorites'),
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       ),
//       body: apiService.favorites.isEmpty
//           ? const Center(child: Text('No favorites yet!'))
//           : ListView.builder(
//               itemCount: apiService.favorites.length,
//               itemBuilder: (context, index) {
//                 final meal = apiService.favorites[index];
//                 return Card(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   child: ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         meal.image,
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     title: Text(
//                       meal.name,
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () async {
//                         await apiService.removeFavorite(meal);
//                       },
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => DetailScreen(meal: meal)),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'detail_user_screen.dart';
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
     
      backgroundColor: Color(0xFFE3AFBC), // Light pink background
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        
      ),
      body: apiService.favorites.isEmpty
          ? const Center(
              child: Text('No favorites yet!',
                  style: TextStyle(fontSize: 18, color: Colors.black54)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 20),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFEE4C74)),
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
