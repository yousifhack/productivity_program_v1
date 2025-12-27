class TaskGroup {
  const TaskGroup({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.createdAtMillis,
  });

  final String id;
  final String name;
  final String ownerUid;
  final int createdAtMillis;

  factory TaskGroup.fromMap(String id, Map<String, dynamic> data) {
    return TaskGroup(
      id: id,
      name: (data['name'] ?? '') as String,
      ownerUid: (data['ownerUid'] ?? '') as String,
      createdAtMillis: (data['createdAtMillis'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'ownerUid': ownerUid,
        'createdAtMillis': createdAtMillis,
      };
}
