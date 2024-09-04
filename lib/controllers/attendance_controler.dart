import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:teacher_app/models/attendance_model.dart.dart';

class AttendanceController {
  final AttendanceModel _model = AttendanceModel();

  Future<void> signInAndInitialize(BuildContext context) async {
    final user = await _model.signInWithGoogle();
    if (user != null) {
      Position position = await _model.getLocation();
      await _model.saveTeacherLocation(user.uid, position);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance marked")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign-in failed")));
    }
  }

  Future<void> generateAttendanceCsv(BuildContext context, String userId) async {
    List<Map<String, dynamic>> studentData = await _model.fetchStudentData(userId);
    List<List<dynamic>> rows = [
      ['Name', 'Email', 'Status'],
      ...studentData.map((student) => [student['name'], student['email'], student['status']]),
    ];

    String csv = const ListToCsvConverter().convert(rows);
    await _saveCsv(context, csv);
  }

  Future<void> _saveCsv(BuildContext context, String csvData) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/attendance_${DateTime.now().toIso8601String()}.csv';
    final file = File(path);
    await file.writeAsString(csvData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('CSV saved at $path')));
  }
}
