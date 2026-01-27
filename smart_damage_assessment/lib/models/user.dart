/// User model for authentication and user data
class User {
  final int id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    print('👤 USER MODEL - Parsing user from JSON: $json');
    try {
      final user = User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String? ?? 'user',
      );
      print('✅ USER MODEL - User parsed successfully: $user');
      return user;
    } catch (e) {
      print('❌ USER MODEL - Failed to parse user: $e');
      rethrow;
    }
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  /// Create a copy of User with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode ^ role.hashCode;
  }
}