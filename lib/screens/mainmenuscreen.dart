import 'package:flutter/material.dart';
import 'package:enrollmentapp/screens/enrollment_screen.dart';
import 'package:enrollmentapp/screens/summary_screen.dart';
import 'package:enrollmentapp/screens/login_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final int studentId;

  const MainMenuScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Log out and navigate back to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnrollmentScreen(studentId: studentId),
                  ),
                );
              },
              child: const Text('Go to Enrollment'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryScreen(studentId: studentId),
                  ),
                );
              },
              child: const Text('View Summary'),
            ),
          ],
        ),
      ),
    );
  }
}
