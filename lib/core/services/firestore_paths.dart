class FirestorePaths {
  static const String users = 'users';
  static const String tasks = 'tasks';
  static const String comments = 'comments';
  static const String events = 'events';

  static String userDoc(String uid) => '$users/$uid';
  static String taskDoc(String taskId) => '$tasks/$taskId';
  static String taskComments(String taskId) => '$tasks/$taskId/$comments';
}
