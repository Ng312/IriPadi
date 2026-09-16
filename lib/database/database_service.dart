import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseDatabase.instance;

  /// Ensures a user is signed in before accessing the database.
  static Future<void> ensureUserSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  /// Reference to the current user's data path
  DatabaseReference get _userRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception(
        'User not logged in — please sign in before using DatabaseService.',
      );
    }
    return _db.ref('irrigation_data/$uid');
  }

  /// Stream to listen for real-time data changes
  Stream<DatabaseEvent> getDataStream() {
    return _userRef.onValue;
  }

  /// Stream to listen for a single day's data to reduce payload size.
  Stream<DatabaseEvent> getDataStreamForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return _userRef
        .orderByChild('timestamp')
        .startAt(formatter.format(start))
        .endAt(formatter.format(end))
        .onValue;
  }

}
