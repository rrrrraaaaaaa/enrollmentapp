import 'package:flutter/material.dart';
import 'package:enrollmentapp/services/database_helper.dart';
import 'package:enrollmentapp/utils/constant.dart';
import 'package:enrollmentapp/screens/summary_screen.dart';

class EnrollmentScreen extends StatelessWidget {
  final int studentId;

  const EnrollmentScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment'),
      ),
      body: FutureBuilder(
        future: dbHelper.getSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading subjects'));
          }

          final subjects = snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return ListTile(
                title: Text(subject['name']),
                subtitle: Text('${subject['credits']} credits'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final totalCredits = await dbHelper.getTotalCredits(studentId);
                    if (totalCredits + subject['credits'] > maxCredits) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Cannot enroll, maximum credits reached!'),
                      ));
                    } else {
                      await dbHelper.insertEnrollment(studentId, subject['id']);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Subject enrolled successfully!'),
                      ));
                    }
                  },
                  child: const Text('Enroll'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryScreen(studentId: studentId),
            ),
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
