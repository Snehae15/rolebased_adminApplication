class AdminUserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool disabled;
  final DateTime createdAt;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.disabled,
    required this.createdAt,
  });
}
