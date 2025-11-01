// screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/attendence.dart';
import '../models/student.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _scannedImage;
  final ImagePicker _picker = ImagePicker();
  List<AttendanceRecord> _todayAttendance = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  Future<void> _loadTodayAttendance() async {
    final today = DateTime.now().toString().split(' ')[0];
    final attendance = await DatabaseHelper.instance.getAttendanceByDate(today);
    setState(() {
      _todayAttendance = attendance;
    });
  }

  Future<void> _scanStudent() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Student Face'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _captureImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _scannedImage = File(image.path);
          _isScanning = true;
        });

        // Simulate face recognition process
        await _processFaceRecognition();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }

  Future<void> _processFaceRecognition() async {
    // Simulate processing time
    await Future.delayed(Duration(seconds: 2));

    try {
      // Get all registered students
      final students = await DatabaseHelper.instance.getAllStudents();

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No registered students found!')),
        );
        setState(() {
          _isScanning = false;
        });
        return;
      }

      // For demo purposes, randomly select a student or show "not found"
      // In real app, this would be actual face recognition
      final random = DateTime.now().millisecondsSinceEpoch % students.length;
      final recognizedStudent = students[random];

      // Check if already marked present today
      final isAlreadyPresent = await DatabaseHelper.instance.isStudentPresentToday(recognizedStudent.studentId);

      if (isAlreadyPresent) {
        _showAlreadyPresentDialog(recognizedStudent);
      } else {
        await _markAttendance(recognizedStudent);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing face recognition: $e')),
      );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _showAlreadyPresentDialog(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Already Present'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.orange, size: 50),
            SizedBox(height: 10),
            Text('${student.name} is already marked present today!'),
            Text('ID: ${student.studentId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAttendance(Student student) async {
    final attendance = AttendanceRecord(
      studentId: student.studentId,
      studentName: student.name,
      scanTime: DateTime.now().toIso8601String(),
      status: 'Present',
    );

    await DatabaseHelper.instance.insertAttendance(attendance);
    await _loadTodayAttendance();

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attendance Marked'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text('${student.name} - Present'),
            Text('ID: ${student.studentId}'),
            Text('Time: ${DateTime.now().toString().split('.')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Scan Student Face',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 30),

            // Camera Section
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _scannedImage == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Tap scan button to capture face',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              )
                  : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _scannedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                    ),
                  ),
                  if (_isScanning)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 10),
                            Text(
                              'Processing...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Scan Button
            ElevatedButton(
              onPressed: _isScanning ? null : _scanStudent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt),
                  SizedBox(width: 10),
                  Text('Scan Student', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Today's Attendance List
            Text(
              'Today\'s Attendance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

            Expanded(
              child: _todayAttendance.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      'No attendance records for today',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _todayAttendance.length,
                itemBuilder: (context, index) {
                  final record = _todayAttendance[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      title: Text(
                        record.studentName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('ID: ${record.studentId}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            record.status,
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            record.formattedTime.split(' ')[1],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTodayAttendance,
        backgroundColor: Colors.blue,
        child: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refresh List',
      ),
    );
  }
}