import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/meal.dart';
import '../../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Meal meal;

  const DetailScreen({super.key, required this.meal});

  @override
  // ignore: library_private_types_in_public_api
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<String> _notes = [];
  TextEditingController noteController = TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController OGnoteController = TextEditingController();
  int? _editingNoteIndex;

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> fetchNotesFromServer(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('_id');

    if (userId == null) {
      throw Exception('No Id found in session');
    }

    final url = Uri.parse('http://localhost:5000/favorites/$mealId/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['note'] != null && data['note'] is List) {
        setState(() {
          _notes = List<String>.from(data['note']);
        });
      } else {
        setState(() {
          _notes = [];
        });
      }
    } else {
      throw Exception('Failed to fetch notes');
    }
  }

  void _editNote(int index) {
    setState(() {
      _editingNoteIndex = index;
      noteController.text = _notes[index];
    });
    _showEditNoteDialog(_editingNoteIndex!);
  }

  void _addNote(ApiService apiService) {
    _showAddNoteDialog(
      apiService,
    );
  }

  // void _showEditNoteDialog(int editingNoteIndex) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Edit Note'),
  //         content: TextField(
  //           controller: noteController,
  //           decoration: const InputDecoration(labelText: 'Edit your note'),
  //           maxLines: 3,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               String updatedNote = noteController.text.trim();
  //               if (updatedNote.isNotEmpty) {
  //                 await _updateNote(updatedNote, editingNoteIndex);
  //               }
  //               // ignore: use_build_context_synchronously
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _showAddNoteDialog(apiService) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Add Note'),
  //         content: TextField(
  //           controller: OGnoteController,
  //           decoration: const InputDecoration(labelText: 'Add your note'),
  //           maxLines: 3,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               String newNote = OGnoteController.text.trim();
  //               if (newNote.isNotEmpty) {
  //                 await apiService.addNoteToMeal(widget.meal.id, newNote);
  //                 OGnoteController.clear();
  //                 fetchNotesFromServer(widget.meal.id);
  //               }
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Add'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showAddNoteDialog(ApiService apiService) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: OGnoteController,
              decoration: const InputDecoration(
                labelText: 'Add your note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    String newNote = OGnoteController.text.trim();
                    if (newNote.isNotEmpty) {
                      await apiService.addNoteToMeal(widget.meal.id, newNote);
                      OGnoteController.clear();
                      fetchNotesFromServer(widget.meal.id);
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void _showEditNoteDialog(int editingNoteIndex) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Edit your note',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    String updatedNote = noteController.text.trim();
                    if (updatedNote.isNotEmpty) {
                      await _updateNote(updatedNote, editingNoteIndex);
                    }
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  Future<void> _updateNote(String updatedNote, int editingNoteIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('_id');

    if (userId == null) {
      throw Exception('No Id found in session');
    }

    final noteId = editingNoteIndex;
    final response = await http.put(
      Uri.parse(
          'http://localhost:5000/favorites/${widget.meal.id}/$userId/note/$noteId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'note': updatedNote,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _notes[noteId] = updatedNote;
      });
    } else {
      throw Exception('Failed to update note');
    }
  }

  Future<void> _deleteNote(int index, String meal) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('_id');

    if (userId == null) {
      throw Exception('No Id found in session');
    }
    final noteToDelete = _notes[index];
    final response = await http.delete(
      Uri.parse('http://localhost:5000/favorites/$meal/$userId/note/$index'),
      body: json.encode({
        'note': noteToDelete,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _notes.removeAt(index);
      });
    } else {
      throw Exception('Failed to delete note');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotesFromServer(widget.meal.id);
  }

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);
    final bool isFavorite = apiService.favorites.contains(widget.meal);

    return Scaffold(
      backgroundColor: const Color(0xFFE3AFBC),
       
      appBar: AppBar(
        title: Text(widget.meal.name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red),
            onPressed: () async {
              await apiService.toggleFavorite(widget.meal, context);
            },
          ),
        ],
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Image.network(widget.meal.image),
            ),
            const SizedBox(height: 16),
            if (widget.meal.videoUrl.isNotEmpty)
              GestureDetector(
                onTap: () => _launchURL(widget.meal.videoUrl),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Watch the video on YouTube',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "สัญชาติ: ${widget.meal.area}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "ประเภท: ${widget.meal.category}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ส่วนประกอบ:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...widget.meal.ingredients
                        .map((ingredient) => Text("• $ingredient",
                            style: const TextStyle(fontSize: 16)))
                        .toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("วิธีทำ:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.meal.instructions,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("หมายเหตุ:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _notes.isEmpty
            ? const Text("ไม่มีหมายเหตุ", style: TextStyle(fontSize: 16))
            : Column(
                children: _notes.asMap().entries.map((entry) {
                  int index = entry.key;
                  String note = entry.value;
                  return ListTile(
                    leading: const Icon(Icons.note, color: Colors.blue),
                    title: Text(note, style: const TextStyle(fontSize: 16)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editNote(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(index, widget.meal.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    ),
  ),
),

            // const SizedBox(height: 16),
            // const Text("หมายเหตุ:",
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 8),
            // _notes.isEmpty
            //     ? const ListTile(
            //         title: Text("ยังไม่มีโน้ต"),
            //         leading: Icon(Icons.info, color: Colors.grey),
            //       )
            //     : ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: _notes.length,
            //         itemBuilder: (context, index) {
            //           return ListTile(
            //             title: Text(_notes[index]),
            //             leading:
            //                 const Icon(Icons.check_circle, color: Colors.green),
            //             trailing: Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 IconButton(
            //                   icon: Icon(Icons.edit),
            //                   onPressed: () => _editNote(index),
            //                 ),
            //                 IconButton(
            //                   icon: Icon(Icons.delete, color: Colors.red),
            //                   onPressed: () =>
            //                       _deleteNote(index, widget.meal.id),
            //                 ),
            //               ],
            //             ),
            //           );
            //         },
            //       ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addNote(apiService);
              },
              child: const Text("เพิ่มโน้ต"),
            ),
          ],
        ),
      ),
    );
  }
}
