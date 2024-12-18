import 'package:flutter/material.dart';
import 'package:enrollmentapp/services/database_helper.dart';

class SummaryScreen extends StatelessWidget {
  final int studentId;

  const SummaryScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: FutureBuilder(
        future: dbHelper.getEnrollments(studentId),  // Get all enrollments for the student
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading enrollments'));
          }

          final enrollments = snapshot.data as List<Map<String, dynamic>>;

          // Get the total credits by summing up the credits for each enrolled subject
          return FutureBuilder(
            future: dbHelper.getTotalCredits(studentId),
            builder: (context, totalCreditsSnapshot) {
              if (totalCreditsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (totalCreditsSnapshot.hasError) {
                return const Center(child: Text('Error calculating total credits'));
              }

              final totalCredits = totalCreditsSnapshot.data as int;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total Credits: $totalCredits',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    if (enrollments.isEmpty)
                      const Text('No subjects enrolled yet.')
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: enrollments.length,
                          itemBuilder: (context, index) {
                            final enrollment = enrollments[index];
                            final subjectId = enrollment['subjectId'];

                            return FutureBuilder(
                              future: dbHelper.getSubjects(),  // Get the subject details
                              builder: (context, subjectSnapshot) {
                                if (subjectSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (subjectSnapshot.hasError) {
                                  return const Center(child: Text('Error loading subjects'));
                                }

                                final subjects = subjectSnapshot.data as List<Map<String, dynamic>>;
                                final subject = subjects.firstWhere(
                                  (subject) => subject['id'] == subjectId,
                                  orElse: () => {'name': 'Unknown Subject', 'credits': 0},
                                );

                                return ListTile(
                                  title: Text(subject['name']),
                                  subtitle: Text('Credits: ${subject['credits']}'),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
