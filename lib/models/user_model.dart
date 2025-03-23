// user_model.dart

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String department;
  final String? section;
  final int? year;
  final String phoneNumber;
  final bool isVerified;
  final String? rollNumber;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
    this.section,
    this.year,
    required this.phoneNumber,
    this.isVerified = false,
    required this.rollNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      department: data['department'] ?? '',
      section: data['section'],
      year: data['year'],
      phoneNumber: data['phoneNumber'] ?? '',
      isVerified: data['isVerified'] ?? false,
      rollNumber: data['rollNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'department': department,
      'section': section,
      'year': year,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'rollNumber' : rollNumber,
    };
  }
}


