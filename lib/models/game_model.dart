class GameModel {
  final String id;
  final String whitePlayerId;
  final String blackPlayerId;
  final String whitePlayerName;
  final String blackPlayerName;
  final String fen; // Board state
  final String status; // 'pending', 'active', 'finished'
  final String? winnerId;
  final int createdAt;
  final int lastMoveAt;
  final String currentTurn; // 'w' or 'b'
  final int whiteTime; // Milliseconds remaining
  final int blackTime; // Milliseconds remaining
  final String? leftBy;

  GameModel({
    required this.id,
    required this.whitePlayerId,
    required this.blackPlayerId,
    required this.whitePlayerName,
    required this.blackPlayerName,
    this.fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    this.status = 'pending',
    this.winnerId,
    required this.createdAt,
    required this.lastMoveAt,
    this.currentTurn = 'w',
    this.whiteTime = 600000, // 10 mins default
    this.blackTime = 600000,
    this.leftBy
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'whitePlayerId': whitePlayerId,
      'blackPlayerId': blackPlayerId,
      'whitePlayerName': whitePlayerName,
      'blackPlayerName': blackPlayerName,
      'fen': fen,
      'status': status,
      'winnerId': winnerId,
      'createdAt': createdAt,
      'lastMoveAt': lastMoveAt,
      'currentTurn': currentTurn,
      'whiteTime': whiteTime,
      'blackTime': blackTime,
      'leftBy': leftBy,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'] ?? '',
      whitePlayerId: map['whitePlayerId'] ?? '',
      blackPlayerId: map['blackPlayerId'] ?? '',
      whitePlayerName: map['whitePlayerName'] ?? '',
      blackPlayerName: map['blackPlayerName'] ?? '',
      fen: map['fen'] ?? 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      status: map['status'] ?? 'pending',
      winnerId: map['winnerId'],
      createdAt: map['createdAt'] ?? 0,
      lastMoveAt: map['lastMoveAt'] ?? 0,
      currentTurn: map['currentTurn'] ?? 'w',
      whiteTime: map['whiteTime'] ?? 600000,
      blackTime: map['blackTime'] ?? 600000,
      leftBy: map['leftBy'] ?? '',
    );
  }

  GameModel copyWith({
    String? id,
    String? whitePlayerId,
    String? blackPlayerId,
    String? whitePlayerName,
    String? blackPlayerName,
    String? fen,
    String? status,
    String? winnerId,
    bool clearWinnerId = false,
    int? createdAt,
    int? lastMoveAt,
    String? currentTurn,
    int? whiteTime,
    int? blackTime,
    String? leftBy,
  }) {
    return GameModel(
      id: id ?? this.id,
      whitePlayerId: whitePlayerId ?? this.whitePlayerId,
      blackPlayerId: blackPlayerId ?? this.blackPlayerId,
      whitePlayerName: whitePlayerName ?? this.whitePlayerName,
      blackPlayerName: blackPlayerName ?? this.blackPlayerName,
      fen: fen ?? this.fen,
      status: status ?? this.status,
      winnerId: clearWinnerId ? null : (winnerId ?? this.winnerId),
      createdAt: createdAt ?? this.createdAt,
      lastMoveAt: lastMoveAt ?? this.lastMoveAt,
      currentTurn: currentTurn ?? this.currentTurn,
      whiteTime: whiteTime ?? this.whiteTime,
      blackTime: blackTime ?? this.blackTime,
      leftBy: leftBy ?? this.leftBy,
    );
  }
}
