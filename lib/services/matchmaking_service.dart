import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import 'package:uuid/uuid.dart';
import '../models/game_model.dart';
import '../controllers/game_controller.dart';

class MatchmakingService extends GetxService {
  final FirestoreService _db = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();
  
  RxBool isSearching = false.obs;
  StreamSubscription? _gameSubscription;
  String? _currentQueueId;
  
  // Challenge Subs
  StreamSubscription? _challengesSubscription;
  StreamSubscription? _sentChallengeSubscription;
  
  @override
  void onReady() {
     super.onReady();
     // Listen for incoming challenges if logged in
     _auth.firebaseUser.listen((user) {
         if (user != null) {
             _listenForChallenges(user.uid);
         } else {
             _challengesSubscription?.cancel();
         }
     });
  }
  
  void _listenForChallenges(String userId) {
      _challengesSubscription?.cancel();
      _challengesSubscription = _db.streamIncomingChallenges(userId).listen((docs) {
          if (docs.isNotEmpty) {
              // Get the most recent one
              final challengeDoc = docs.first; // Should ideally sort by time
              final data = challengeDoc.data() as Map<String, dynamic>;
              
              // Prevent multiple dialogs?
              if (Get.isDialogOpen ?? false) return; 
              
              Get.defaultDialog(
                  title: "Game Challenge",
                  middleText: "${data['fromName'] ?? 'Someone'} wants to play!",
                  textCancel: "Reject",
                  textConfirm: "Accept",
                  onCancel: () {
                      _db.updateChallenge(challengeDoc.id, {'status': 'rejected'});
                  },
                  onConfirm: () {
                      Get.back(); // close dialog
                      _acceptChallenge(challengeDoc.id, data);
                  },
                  barrierDismissible: false
              );
          }
      });
  }
  
  Future<void> sendChallenge(String opponentId) async {
      final user = _auth.appUser.value;
      if (user == null) return;
      
      try {
          // Check if opponent exists (optional but good)
          final oppUser = await _db.getUser(opponentId);
          if (oppUser == null) {
              Get.snackbar("Error", "User not found");
              return;
          }
          
          final challengeId = await _db.sendChallenge({
              'fromId': user.id,
              'fromName': user.username,
              'toId': opponentId,
              'status': 'pending',
              'createdAt': DateTime.now().millisecondsSinceEpoch,
          });
          
          Get.dialog(
              const Center(child: CircularProgressIndicator()), 
              barrierDismissible: false
          );
          
          // Listen for response
          _sentChallengeSubscription?.cancel();
          _sentChallengeSubscription = _db.streamChallenge(challengeId).listen((snap) {
              if (!snap.exists) return;
              final data = snap.data() as Map<String, dynamic>;
              final status = data['status'];
              
              if (status == 'accepted') {
                   // Game ID should be there
                   if (Get.isDialogOpen ?? false) Get.back(); // Close loading
                   _sentChallengeSubscription?.cancel();
                   
                   // Get game
                   _db.streamGame(data['gameId']).first.then((game) {
                       _startGame(game, 'w'); // Sender is White (convention here)
                   });
              } else if (status == 'rejected') {
                   if (Get.isDialogOpen ?? false) Get.back();
                   _sentChallengeSubscription?.cancel();
                   Get.snackbar("Rejected", "Challenge was rejected.");
              }
          });
          
      } catch (e) {
          Get.snackbar("Error", "Could not send challenge: $e");
      }
  }
  
  Future<void> _acceptChallenge(String challengeId, Map<String, dynamic> challengeData) async {
       final user = _auth.appUser.value;
       if (user == null) return;
       
       try {
           final newGame = GameModel(
                 id: const Uuid().v4(),
                 whitePlayerId: challengeData['fromId'],
                 blackPlayerId: user.id,
                 whitePlayerName: challengeData['fromName'],
                 blackPlayerName: user.username,
                 createdAt: DateTime.now().millisecondsSinceEpoch,
                 lastMoveAt: DateTime.now().millisecondsSinceEpoch,
                 status: 'active' 
           );
           
           await _db.createGame(newGame);
           
           // Update challenge
           await _db.updateChallenge(challengeId, {
               'status': 'accepted',
               'gameId': newGame.id
           });
           
           _startGame(newGame, 'b'); // Accepter is Black
           
       } catch (e) {
           Get.snackbar("Error", "Failed to start game: $e");
       }
  }

  
  Future<void> findMatch() async {
    final user = _auth.appUser.value;
    if (user == null) return;
    
    // Prevent double search
    if (isSearching.value) return;
    
    isSearching.value = true;
    Get.snackbar("Matchmaking", "Looking for an opponent...");
    
    try {
      final queueSnapshot = await _db.getQueue();
      bool matchFound = false;
      
      for (var doc in queueSnapshot.docs) {
         final data = doc.data() as Map<String, dynamic>;
         if (data['userId'] != user.id) {
             // Found Opponent
             String opponentId = data['userId'];
             
             // Try to delete their queue entry to claim them
             // In a real app verify existence or use transaction
             try {
                await _db.leaveQueue(doc.id);
             } catch (e) {
                // Someone else took this player, continue
                continue; 
             }
             
             final newGame = GameModel(
                 id: const Uuid().v4(),
                 whitePlayerId: user.id,
                 blackPlayerId: opponentId,
                 whitePlayerName: user.username,
                 blackPlayerName: data['username'] ?? 'Opponent',
                 createdAt: DateTime.now().millisecondsSinceEpoch,
                 lastMoveAt: DateTime.now().millisecondsSinceEpoch,
                 status: 'pending' 
             );
             
             await _db.createGame(newGame);
             matchFound = true;
             
             _startGame(newGame, 'w');
             return;
         }
      }
      
      if (!matchFound) {
          // Join Queue
          _currentQueueId = await _db.joinQueue(user);
          Get.snackbar("Matchmaking", "Added to queue. Waiting for opponent...");
          
          // Listen for games where I am Black (passive join)
          _gameSubscription = _db.streamMyPendingGames(user.id).listen((games) {
              if (games.isNotEmpty) {
                  // Found one!
                  // Ideally pick the newest one
                   games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                   final game = games.first;
                   
                   // Clean up queue
                   if (_currentQueueId != null) {
                       _db.leaveQueue(_currentQueueId!);
                       _currentQueueId = null;
                   }
                   
                   _startGame(game, 'b');
              }
          });
      }
      
    } catch (e) {
      isSearching.value = false;
      Get.snackbar("Error", "Matchmaking failed: $e");
    }
  }
  
  void _startGame(GameModel game, String myColor) {
      isSearching.value = false;
      _gameSubscription?.cancel();
      _gameSubscription = null;
      
      Get.find<GameController>().startGame(
         mode: GameMode.online,
         onlineGame: game,
         asColor: myColor
      );
      Get.toNamed('/game');
  }
  
  void cancelSearch() {
      if (_currentQueueId != null) {
          _db.leaveQueue(_currentQueueId!);
          _currentQueueId = null;
      }
      _gameSubscription?.cancel();
      isSearching.value = false;
  }
  
  @override
  void onClose() {
      cancelSearch();
      _challengesSubscription?.cancel();
      _sentChallengeSubscription?.cancel();
      super.onClose();
  }
}
