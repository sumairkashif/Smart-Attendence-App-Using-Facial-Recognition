// database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/attendence.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('attendance.db');
    return _database!;
  }

  Future<void> deleteAllStudents() async {
    final db = await database;
    await db.delete('students');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        face_encoding TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        student_name TEXT NOT NULL,
        scan_time TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (student_id)
      )
    ''');
  }

  // Student CRUD operations
  Future<int> insertStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('students', student.toJson());
  }

  Future<List<Student>> getAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students', orderBy: 'name ASC');
    return result.map((json) => Student.fromJson(json)).toList();
  }

  Future<Student?> getStudentById(String studentId) async {
    final db = await instance.database;
    final result = await db.query(
      'students',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    if (result.isNotEmpty) {
      return Student.fromJson(result.first);
    }
    return null;
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return await db.update(
      'students',
      student.toJson(),
      where: 'student_id = ?',
      whereArgs: [student.studentId],
    );
  }

  Future<int> deleteStudent(String studentId) async {
    final db = await instance.database;
    // Also delete attendance records for this student
    await db.delete(
      'attendance',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    return await db.delete(
      'students',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }

  // Attendance operations
  Future<int> insertAttendance(AttendanceRecord attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance.toJson());
  }

  Future<List<AttendanceRecord>> getAllAttendance() async {
    final db = await instance.database;
    final result = await db.query('attendance', orderBy: 'scan_time DESC');
    return result.map((json) => AttendanceRecord.fromJson(json)).toList();
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'attendance',
      where: 'scan_time LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'scan_time DESC',
    );
    return result.map((json) => AttendanceRecord.fromJson(json)).toList();
  }

  Future<bool> isStudentPresentToday(String studentId) async {
    final db = await instance.database;
    final today = DateTime.now().toString().split(' ')[0];
    final result = await db.query(
      'attendance',
      where: 'student_id = ? AND scan_time LIKE ?',
      whereArgs: [studentId, '$today%'],
    );
    return result.isNotEmpty;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}