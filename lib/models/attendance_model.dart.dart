import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AttendanceModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error in Google Sign-In: $e");
      return null;
    }
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  Future<void> saveTeacherLocation(String userId, Position position) async {
    await _dbRef.child('teachers/$userId/location').set({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  Future<List<Map<String, dynamic>>> fetchStudentData(String userId) async {
    DataSnapshot snapshot = await _dbRef.child('students').once();
    List<Map<String, dynamic>> studentData = [];
    if (snapshot.value != null) {
      Map<dynamic, dynamic> students = snapshot.value as Map<dynamic, dynamic>;
      for (var student in students.values) {
        double distance = Geolocator.distanceBetween(
          student['latitude'],
          student['longitude'],
          snapshot.child('teachers/$userId/location/latitude').value,
          snapshot.child('teachers/$userId/location/longitude').value,
        );
        String status = distance <= 20 ? 'Present' : 'Absent';
        studentData.add({
          'name': student['name'],
          'email': student['email'],
          'status': status,
        });
      }
    }
    return studentData;
  }
}
