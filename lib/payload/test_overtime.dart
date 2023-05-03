class Overtime {
  final int id;
  final String userId;
  final DateTime overtimeAt;
  final String overtimeStatus;
  final String desc;
  final String attachment;
  final User user;

  Overtime({
    required this.id,
    required this.userId,
    required this.overtimeAt,
    required this.overtimeStatus,
    required this.desc,
    required this.attachment,
    required this.user,
  });
}

class User {
  final String id;
  final String userCode;
  final String username;
  final String name;

  User({
    required this.id,
    required this.userCode,
    required this.username,
    required this.name,
  });
}
