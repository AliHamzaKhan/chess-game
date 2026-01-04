class AppUser {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final int points;
  final int wins;
  final int losses;
  final int matchesPlayed;
  final int level;
  final bool isOnline;
  final int lastSeen;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    this.points = 1000,
    this.wins = 0,
    this.losses = 0,
    this.matchesPlayed = 0,
    this.level = 1,
    this.isOnline = false,
    this.lastSeen = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'wins': wins,
      'losses': losses,
      'matchesPlayed': matchesPlayed,
      'level': level,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      points: map['points'] ?? 1000,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      matchesPlayed: map['matchesPlayed'] ?? 0,
      level: map['level'] ?? 1,
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? 0,
    );
  }
}
