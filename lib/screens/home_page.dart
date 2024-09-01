import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
              ),
              child: const Text(
                'I have taken the attendance',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
              ),
              child: const Text(
                'Create Attendance Excel',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: TextFormField(
        decoration: const InputDecoration(
          hintText: "Enter File Name",
        ),
      ),
    );
  }
}
