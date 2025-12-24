class AppUser {
  final String uid;
  final String role; // manager | employee
  final String displayName;
  final String teamId;

  AppUser({
    required this.uid,
    required this.role,
    required this.displayName,
    required this.teamId,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      role: (data['role'] ?? 'employee') as String,
      displayName: (data['displayName'] ?? 'User') as String,
      teamId: (data['teamId'] ?? 'demo') as String,
    );
  }
}
