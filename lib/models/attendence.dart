// models/attendance_model.dart
class AttendanceRecord {
  final int? id;
  final String studentId;
  final String studentName;
  final String scanTime;
  final String status;

  AttendanceRecord({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.scanTime,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      studentId: json['student_id'],
      studentName: json['student_name'],
      scanTime: json['scan_time'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'scan_time': scanTime,
      'status': status,
    };
  }

  String get formattedTime {
    final dateTime = DateTime.parse(scanTime);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}