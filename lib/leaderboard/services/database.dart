import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jungle_jumper/game/player/highscore_text.dart';
import 'package:jungle_jumper/leaderboard/models/highscore_data.dart';
import 'package:jungle_jumper/leaderboard/models/player.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  HighscoreText? highscoreText;
  QuerySnapshot? snapshot;

  // Collection reference
  final CollectionReference<Map<String, dynamic>> highscoresCollection =
      FirebaseFirestore.instance.collection('highscores');

  // Update user data
  Future<void> updateUserData(String name, int score) async {
    return await highscoresCollection.doc(uid).set({
      'score': score,
      'name': name,
    });
  }

  // Highscores list from snapshot
  List<HighscoreData> _highscoresListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return HighscoreData(
        name: doc.get('name') ?? '',
        score: doc.get('score') ?? 0,
      );
    }).toList();
  }

  dynamic score;

  // User data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    score = snapshot.get('score');
    return UserData(
      uid: uid!,
      name: snapshot.get('name'),
      score: snapshot.get('score'),
    );
  }

  // Get highscores stream
  Stream<List<HighscoreData>> get highscoreData {
    return highscoresCollection
        .where('score',
            isLessThanOrEqualTo: score + 100,
            isGreaterThanOrEqualTo: score - 100)
        .orderBy('score', descending: true)
        .limit(100)
        .snapshots()
        .map(_highscoresListFromSnapshot);
  }

  // Get user document
  Stream<UserData> get userData {
    return highscoresCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
