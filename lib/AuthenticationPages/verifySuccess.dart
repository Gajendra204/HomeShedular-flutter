import 'package:flutter/material.dart';

import 'homescreen.dart';

class VerifySuccess extends StatefulWidget {
  const VerifySuccess({super.key});

  @override
  State<VerifySuccess> createState() => _VerifySuccessState();
}

class _VerifySuccessState extends State<VerifySuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 70),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        "SHEDULAR",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    Center(
                      child: Container(
                        height: 200,
                        child: Image.asset('Assets/images/man.png'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Mobile verification has successfully done",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 30),

              // ✅ Added Button to Navigate to Home Page
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage()), // ✅ Explicitly navigating to HomePage
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Go to Home",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
