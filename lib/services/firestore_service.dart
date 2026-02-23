import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';
import '../models/game_model.dart';
import '../models/friend_request.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Operations
  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }
  
  Stream<AppUser?> streamUser(String uid) {
      return _db.collection('users').doc(uid).snapshots().map((doc) {
          if (doc.exists) return AppUser.fromMap(doc.data()!);
          return null;
      });
  }
  
  Future<void> updateUserStats(String uid, int pointsChange, String result) async {
      // result can be 'win', 'loss', or 'draw'
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) return;
      
      final currentData = AppUser.fromMap(userDoc.data()!);
      int newPoints = currentData.points + pointsChange;
      int newWins = result == 'win' ? currentData.wins + 1 : currentData.wins;
      int newLosses = result == 'loss' ? currentData.losses + 1 : currentData.losses;
      int matches = currentData.matchesPlayed + 1;
      
      // Simple level calculation
      int newLevel = (newPoints / 100).floor(); 
      if (newLevel < 1) newLevel = 1;

      await _db.collection('users').doc(uid).update({
          'points': newPoints,
          'wins': newWins,
          'losses': newLosses,
          'matchesPlayed': matches,
          'level': newLevel,
          'ratingHistory': FieldValue.arrayUnion([newPoints]),
      });
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return;
      
      await _db.collection('users').doc(uid).update({
          'isOnline': isOnline,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
  }

  // Game Operations
  Future<void> createGame(GameModel game) async {
    await _db.collection('games').doc(game.id).set(game.toMap());
  }

  Future<void> updateGame(GameModel game) async {
    await _db.collection('games').doc(game.id).update(game.toMap());
  }

  Stream<GameModel> streamGame(String gameId) {
    return _db.collection('games').doc(gameId).snapshots().map((doc) {
      // If doc is null/deleted, handle externally or throw
      if (!doc.exists) throw Exception("Game not found");
      return GameModel.fromMap(doc.data()!);
    });
  }

  Stream<List<GameModel>> streamMyPendingGames(String userId) {
      return _db.collection('games')
          .where('blackPlayerId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending') // Or 'active' if creator starts it immediately
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => GameModel.fromMap(d.data())).toList());
  }

  Stream<List<GameModel>> streamMyMatchHistory(String userId) {
      return _db.collection('games')
          .where(Filter.or(
             Filter('whitePlayerId', isEqualTo: userId),
             Filter('blackPlayerId', isEqualTo: userId)
          ))
          .where('status', isEqualTo: 'finished')
          .orderBy('lastMoveAt', descending: true)
          .limit(10)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => GameModel.fromMap(d.data())).toList());
  }

  // Queue Operations
  Future<String?> joinQueue(AppUser user) async {
      // Add check if already in queue or not
      // For simplicity, just add to a 'matchmakingQueue' collection
      // Returns queue ID
      final docRef = await _db.collection('matchmakingQueue').add({
          'userId': user.id,
          'username': user.username,
          'points': user.points,
          'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
  }
  
  Future<void> leaveQueue(String queueId) async {
      await _db.collection('matchmakingQueue').doc(queueId).delete();
  }
  
  Future<QuerySnapshot> getQueue() {
      // Get oldest in queue
      return _db.collection('matchmakingQueue')
          .orderBy('createdAt')
          .limit(2) // Get a few to Find a match
          .get();
  }

  // Leaderboard
  Stream<List<AppUser>> getLeaderboard() {
      return _db.collection('users')
          .orderBy('points', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) => AppUser.fromMap(d.data())).toList());
  }

  // Challenges
  Future<String> sendChallenge(Map<String, dynamic> challengeData) async {
      final doc = await _db.collection('challenges').add(challengeData);
      return doc.id;
  }
  
  Stream<List<QueryDocumentSnapshot>> streamIncomingChallenges(String userId) {
      return _db.collection('challenges')
          .where('toId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snap) => snap.docs);
  }
  
  Stream<DocumentSnapshot> streamChallenge(String challengeId) {
      return _db.collection('challenges').doc(challengeId).snapshots();
  }
  
  Future<void> updateChallenge(String id, Map<String, dynamic> data) async {
      await _db.collection('challenges').doc(id).update(data);
  }

  // Friends Operations
  Future<void> addFriend(String userId, AppUser friend) async {
    await _db.collection('users').doc(userId).collection('friends').doc(friend.id).set(friend.toMap());
  }

  Future<void> removeFriend(String userId, String friendId) async {
    await _db.collection('users').doc(userId).collection('friends').doc(friendId).delete();
  }

  Stream<List<AppUser>> streamFriends(String userId) {
    return _db.collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => AppUser.fromMap(d.data())).toList());
  }

  // Friend Requests
  Future<void> sendFriendRequest(String fromId, String fromName, String toId) async {
    final docId = '${fromId}_${toId}';
    await _db.collection('friend_requests').doc(docId).set({
      'id': docId,
      'fromId': fromId,
      'fromName': fromName,
      'toId': toId,
      'status': 'pending',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<FriendRequest>> streamIncomingFriendRequests(String userId) {
    return _db.collection('friend_requests')
        .where('toId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) => FriendRequest.fromMap(d.data())).toList());
  }

  Future<void> acceptFriendRequest(FriendRequest request) async {
    // 1. Mark request as accepted (or just delete it)
    await _db.collection('friend_requests').doc(request.id).update({'status': 'accepted'});

    // 2. Add to both users' friends lists
    final fromUser = await getUser(request.fromId);
    final toUser = await getUser(request.toId);

    if (fromUser != null && toUser != null) {
      // Add 'To' to 'From's list
      await addFriend(request.fromId, toUser);
      // Add 'From' to 'To's list
      await addFriend(request.toId, fromUser);
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _db.collection('friend_requests').doc(requestId).delete();
  }
}
