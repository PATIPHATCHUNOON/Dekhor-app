// user_model.dart — โครงสร้างข้อมูล User

class UserModel {
  final String  id;
  final String  username;
  final String  email;
  final String? fullName;
  final String? avatarUrl;
  final String? university;
  final String? dormName;
  final String? roomNumber;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.university,
    this.dormName,
    this.roomNumber,
  });

  // แปลง JSON จาก API → UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:          json['id'],
      username:    json['username'],
      email:       json['email'],
      fullName:    json['full_name'],
      avatarUrl:   json['avatar_url'],
      university:  json['university'],
      dormName:    json['dorm_name'],
      roomNumber:  json['room_number'],
    );
  }

  // แปลง UserModel → JSON (ส่งไป API)
  Map<String, dynamic> toJson() => {
    'id':          id,
    'username':    username,
    'email':       email,
    'full_name':   fullName,
    'avatar_url':  avatarUrl,
    'university':  university,
    'dorm_name':   dormName,
    'room_number': roomNumber,
  };

  // copyWith — แก้ไขบางฟิลด์โดยไม่เปลี่ยนอันอื่น
  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? university,
    String? dormName,
    String? roomNumber,
  }) {
    return UserModel(
      id:          id,
      username:    username,
      email:       email,
      fullName:    fullName    ?? this.fullName,
      avatarUrl:   avatarUrl   ?? this.avatarUrl,
      university:  university  ?? this.university,
      dormName:    dormName    ?? this.dormName,
      roomNumber:  roomNumber  ?? this.roomNumber,
    );
  }
}