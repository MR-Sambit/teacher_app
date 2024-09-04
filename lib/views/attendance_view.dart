import 'package:flutter/material.dart';
import 'package:teacher_app/controllers/attendance_controler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  _AttendanceViewState createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final AttendanceController _controller = AttendanceController();
  User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Attendance App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user != null) Text('Welcome, ${_user!.displayName}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _controller.signInAndInitialize(context);
                setState(() {
                  _user = FirebaseAuth.instance.currentUser;
                });
              },
              child: const Text('Mark Attendance'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _user != null
                  ? () => _controller.generateAttendanceCsv(context, _user!.uid)
                  : null,
              child: const Text('Generate Attendance CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
