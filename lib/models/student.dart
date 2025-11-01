// models/student_model.dart
class Student {
  final int? id;
  final String studentId;
  final String name;
  final String? faceEncoding;
  final String createdAt;

  Student({
    this.id,
    required this.studentId,
    required this.name,
    this.faceEncoding,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentId: json['student_id'],
      name: json['name'],
      faceEncoding: json['face_encoding'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'face_encoding': faceEncoding,
      'created_at': createdAt,
    };
  }

  Student copyWith({
    int? id,
    String? studentId,
    String? name,
    String? faceEncoding,
    String? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      faceEncoding: faceEncoding ?? this.faceEncoding,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}