// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';

// class OtpPage extends StatefulWidget {
//   const OtpPage({super.key});

//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           //width: double.infinity,
//           decoration: BoxDecoration(
//             color: Colors.white,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               SizedBox(
//                 height: 70,
//               ),
//               Padding(
//                 padding: EdgeInsets.only(left: 0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Center(
//                         child: Text(
//                       "SHEDULAR",
//                       style: TextStyle(
//                           color: Colors.deepPurple,
//                           fontSize: 60,
//                           fontWeight: FontWeight.bold),
//                     )),
//                     SizedBox(
//                       height: 7,
//                     ),
//                     //Text("Welcome Back", style: TextStyle(color: Colors.white, fontSize: 18),)
//                     Center(
//                         child: Container(
//                             height: 200,
//                             child: Image.asset('Assets/images/man.png'))),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 50),
//               Container(
//                 decoration: BoxDecoration(
//                     color: Colors.deepPurple,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(60),
//                         topRight: Radius.circular(60))),
//                 child: Padding(
//                   padding: EdgeInsets.all(30),
//                   child: Column(
//                     children: <Widget>[
//                       Row(children: [
//                         Text("OTP Verification",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold)),
//                       ]),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Row(children: [
//                         Text("An 4 digit code has been sent to your number",
//                             style:
//                                 TextStyle(color: Colors.white, fontSize: 16)),
//                       ]),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Container(
//                         child: Column(
//                           children: <Widget>[
//                             Pinput(
//                               length: 4,
//                               showCursor: true,
//                               defaultPinTheme: PinTheme(
//                                   width: 50,
//                                   height: 60,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(color: Colors.white)),
//                                   textStyle: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w600,
//                                   )),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       MaterialButton(
//                         onPressed: () {
//                           Navigator.pushNamed(context, 'verifySuccess');
//                         },
//                         height: 50,
//                         // margin: EdgeInsets.symmetric(horizontal: 50),
//                         color: Colors.yellowAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                         // decoration: BoxDecoration(
//                         // ),
//                         child: Center(
//                           child: Text(
//                             "Verify OTP",
//                             style: TextStyle(
//                                 color: Colors.black87,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 25,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'If you did not receive a code!',
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.white,
//                             ),
//                           ),
//                           GestureDetector(
//                               child: Text(
//                             ' Resend',
//                             style: TextStyle(color: Colors.yellowAccent),
//                           )),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 25,
//                       ),
//                       Row(
//                         children: <Widget>[
//                           SizedBox(
//                             height: 45,
//                           ),
//                           Expanded(
//                               child: OutlinedButton(
//                             child: Text(
//                               'Change Mobile Number',
//                               style: TextStyle(fontSize: 18),
//                             ),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               backgroundColor: Colors.transparent,
//                               shape: const RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(10))),
//                               side: BorderSide(color: Colors.white, width: 1),
//                             ),
//                             onPressed: () {
//                               print('Pressed');
//                             },
//                           )),
//                         ],
//                       ),
//                       SizedBox(height: 30),
//                       SizedBox(
//                         height: 48,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "By signing up,you agree to our ",
//                             style: TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                           GestureDetector(
//                               onTap: () {
//                                 print("Terms of use");
//                               },
//                               child: Text(
//                                 "Terms of Use",
//                                 style: TextStyle(
//                                     color: Colors.yellow, fontSize: 12),
//                               )),
//                           Text(
//                             " and ",
//                             style: TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                           GestureDetector(
//                               onTap: () {
//                                 print("Privacy Policy");
//                               },
//                               child: Text(
//                                 "Privacy Policy",
//                                 style: TextStyle(
//                                     color: Colors.yellow, fontSize: 12),
//                               )),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
