import 'package:flutter/material.dart';
import 'package:enrollmentapp/services/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Create an instance of DatabaseHelper to insert new users
  final dbHelper = DatabaseHelper();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed with registration
      final username = _usernameController.text;
      final password = _passwordController.text;

      // Add user to database
      await dbHelper.insertUser(username, password);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User registered successfully!'),
      ));

      // Navigate back to Login screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,  // Register button triggers the validation and registration process
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  