class Colleague {
  const Colleague({
    required this.uid,
    required this.displayName,
    required this.publicId,
    required this.lastSeenAtMillis,
    required this.unread,
  });

  final String uid;
  final String displayName;
  final String publicId;
  final int lastSeenAtMillis; // derived presence
  final bool unread; // placeholder for star

  factory Colleague.fromMap(Map<String, dynamic> data) {
    return Colleague(
      uid: (data['uid'] ?? '') as String,
      displayName: (data['displayName'] ?? 'User') as String,
      publicId: (data['publicId'] ?? '') as String,
      lastSeenAtMillis: (data['lastSeenAtMillis'] ?? 0) as int,
      unread: (data['unread'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'publicId': publicId,
        'lastSeenAtMillis': lastSeenAtMillis,
        'unread': unread,
      };
}
