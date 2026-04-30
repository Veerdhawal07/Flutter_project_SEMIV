enum UserRole { user, admin, officer }

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePic;
  final UserRole role;

  
  final String? address;
  final String? villageName;
  final String? wardNumber;
  final String? aadhaarId;
  final String? gender;
  final String? occupation;
  final String? houseNumber;

  
  final String? department;
  final String? area;
  final String? officerId;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.role,
    this.address,
    this.villageName,
    this.wardNumber,
    this.aadhaarId,
    this.gender,
    this.occupation,
    this.houseNumber,
    this.department,
    this.area,
    this.officerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePic': profilePic,
      'role': role.name,
      'address': address,
      'villageName': villageName,
      'wardNumber': wardNumber,
      'aadhaarId': aadhaarId,
      'gender': gender,
      'occupation': occupation,
      'houseNumber': houseNumber,
      'department': department,
      'area': area,
      'officerId': officerId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profilePic: map['profilePic'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      address: map['address'],
      villageName: map['villageName'],
      wardNumber: map['wardNumber'],
      aadhaarId: map['aadhaarId'],
      gender: map['gender'],
      occupation: map['occupation'],
      houseNumber: map['houseNumber'],
      department: map['department'],
      area: map['area'],
      officerId: map['officerId'],
    );
  }
}
