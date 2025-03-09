import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _register() async {
    setState(() => isLoading = true);
    const String apiUrl = "http://localhost:5000/user/register";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      final errorMessage = jsonDecode(response.body)["error"];
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.pink.shade200, Colors.pink.shade50],
                center: const Alignment(0, -0.3),
                radius: 1.5,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    cursorColor: const Color(0xFFEE4C74),
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), 
                      floatingLabelStyle: TextStyle(color: Color(0xFFEE4C74)), 
                      prefixIcon: Icon(Icons.person, color: Colors.pink),
                      filled: true,
                      fillColor: Colors.white,
                       focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEE4C74)),
                        
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                 TextField(
                    cursorColor: const Color(0xFFEE4C74),
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), 
                      floatingLabelStyle: TextStyle(color: Color(0xFFEE4C74)), 
                      prefixIcon: Icon(Icons.email, color: Colors.pink),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEE4C74)),
                        
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    cursorColor: const Color(0xFFEE4C74),
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), 
                      floatingLabelStyle: TextStyle(color: Color(0xFFEE4C74)), 
                      prefixIcon: Icon(Icons.lock, color: Colors.pink),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEE4C74)),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFEE4C74)), // กำหนดสีที่ต้องการ
              ),
            )
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 15),
                          ),
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Already have an account? Login here",
                      style: TextStyle(
                        color: Colors.pink.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
