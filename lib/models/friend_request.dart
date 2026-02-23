class FriendRequest {
  final String id;
  final String fromId;
  final String fromName;
  final String toId;
  final String status; // 'pending', 'accepted', 'rejected'
  final int createdAt;

  FriendRequest({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.toId,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromId': fromId,
      'fromName': fromName,
      'toId': toId,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'] ?? '',
      fromId: map['fromId'] ?? '',
      fromName: map['fromName'] ?? '',
      toId: map['toId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? 0,
    );
  }
}
