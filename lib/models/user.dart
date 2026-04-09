class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? username;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] ?? json['full_name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'staff',
        username: json['username'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'username': username,
      };
}
