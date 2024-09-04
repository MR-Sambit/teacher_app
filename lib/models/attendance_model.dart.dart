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
  if (position != null) {
    try {
      await _dbRef.child('teachers/$userId/location').set({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    } catch (e) {
      // Handle error
      print('Error saving teacher location: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> fetchStudentData(String userId) async {
  try {
    // Fetch all student data
    DatabaseEvent studentEvent = await _dbRef.child('students').once();
    List<Map<String, dynamic>> studentData = [];

    if (studentEvent.snapshot.value != null) {
      Map<dynamic, dynamic> students = studentEvent.snapshot.value as Map<dynamic, dynamic>;

      // Fetch teacher's location
      DatabaseEvent teacherLatEvent = await _dbRef.child('teachers/$userId/location/latitude').once();
      DatabaseEvent teacherLongEvent = await _dbRef.child('teachers/$userId/location/longitude').once();

      double teacherLatitude = (teacherLatEvent.snapshot.value as num).toDouble();
      double teacherLongitude = (teacherLongEvent.snapshot.value as num).toDouble();

      for (var student in students.values) {
        if (student != null && student is Map<dynamic, dynamic>) {
          // Cast latitude and longitude to double
          double studentLatitude = (student['latitude'] as num).toDouble();
          double studentLongitude = (student['longitude'] as num).toDouble();

          double distance = Geolocator.distanceBetween(
            studentLatitude,
            studentLongitude,
            teacherLatitude,
            teacherLongitude,
          );

          String status = distance <= 20 ? 'Present' : 'Absent';
          studentData.add({
            'name': student['name'],
            'email': student['email'],
            'status': status,
          });
        }
      }
    }
    return studentData;
  } catch (e) {
    // Handle error
    print('Error fetching student data: $e');
    rethrow;
  }
}
}
