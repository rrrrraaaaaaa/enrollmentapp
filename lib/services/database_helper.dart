import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'student_enrollment.db');
    return await openDatabase(path, onCreate: (db, version) async {
      // Create tables for students, subjects, and enrollments
      await db.execute(''' 
        CREATE TABLE students(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          password TEXT
        );
      ''');

      await db.execute(''' 
        CREATE TABLE subjects(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          credits INTEGER
        );
      ''');

      await db.execute(''' 
        CREATE TABLE enrollments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          studentId INTEGER,
          subjectId INTEGER,
          FOREIGN KEY (studentId) REFERENCES students(id),
          FOREIGN KEY (subjectId) REFERENCES subjects(id)
        );
      ''');

      // Insert default subjects into the subjects table
      List<Map<String, dynamic>> subjects = [
        {'name': 'Data Structure Algorithm', 'credits': 4},
        {'name': 'Ethical Hacking', 'credits': 4},
        {'name': 'Parallel Programming', 'credits': 4},
        {'name': 'Mobile Programming', 'credits': 4},
        {'name': '3D Programming', 'credits': 4},
        {'name': 'Computer Architecture', 'credits': 4},
        {'name': 'Programming Concept', 'credits': 4},
        {'name': 'OOVP', 'credits': 4},
        {'name': 'Wireless Programming', 'credits': 4},
        {'name': 'Digital Forensics', 'credits': 4},
      ];

      for (var subject in subjects) {
        await db.insert('subjects', subject);
      }
    }, version: 1);
  }

  // Insert a new user (student) into the students table
  Future<void> insertUser(String username, String password) async {
    final db = await database;
    await db.insert('students', {'username': username, 'password': password});
  }

  // Retrieve a user by username and password
  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Insert a subject enrollment into the enrollments table
  Future<void> insertEnrollment(int studentId, int subjectId) async {
    final db = await database;
    await db.insert('enrollments', {'studentId': studentId, 'subjectId': subjectId});
  }

  // Get all subjects available for enrollment
  Future<List<Map<String, dynamic>>> getSubjects() async {
    final db = await database;
    return await db.query('subjects');
  }

  // Get all subjects that a student has enrolled in
  Future<List<Map<String, dynamic>>> getEnrollments(int studentId) async {
    final db = await database;
    return await db.query(
      'enrollments',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
  }

  // Get the total credits a student has enrolled in
  Future<int> getTotalCredits(int studentId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(subjects.credits) AS totalCredits
      FROM enrollments
      JOIN subjects ON enrollments.subjectId = subjects.id
      WHERE enrollments.studentId = ?
    ''', [studentId]);

    return result.isNotEmpty && result[0]['totalCredits'] != null
        ? result[0]['totalCredits'] as int
        : 0;
  }
}
