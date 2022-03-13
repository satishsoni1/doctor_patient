import 'dart:async';
import 'dart:convert';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/views/Doctor/DoctorTabScreen.dart';
import 'package:book_appointment/views/RegisterAsUser.dart';
import 'package:email_validator/email_validator.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ForgetPassword.dart';
import '../HomeScreen.dart';
import 'RegisterAsDoctor.dart';

class LoginAsDoctor extends StatefulWidget {
  @override
  _LoginAsDoctorState createState() => _LoginAsDoctorState();
}

class _LoginAsDoctorState extends State<LoginAsDoctor> {
  String emailAddress = "";
  String pass = "";
  bool isPhoneNumberError = false;
  bool isPasswordError = false;
  String passErrorText = "";
  String token = "";
  bool isTokenPresent = false;

  getToken() async {
    await SharedPreferences.getInstance().then((pref) async {
      if (pref.getBool("isTokenExist") ?? false) {
        // String tokenLocal = await FirebaseMessaging.instance.getToken();
        String tokenLocal = "0";
        setState(() {
          print("1-> token retrieved");
          token = tokenLocal;
        });
      }
    });
  }

  storeToken() async {
    dialog();
    // await FirebaseMessaging.instance.getToken().then((value) async {
    //   //Toast.show(value, context, duration: 2);
    //   print(value);
    //   setState(() {
    //     token = value;
    //   });

    final response = await post("$SERVER_ADDRESS/api/savetoken", body: {
      //"token": token,
      "token": "0",
      "type": "1",
    }).catchError((e) {
      Navigator.pop(context);
      messageDialog(ERROR, UNABLE_TO_SAVE_TOKEN_TO_SERVER);
    });
    if (response.statusCode == 200) {
      Navigator.pop(context);
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'].toString() == "1") {
        SharedPreferences.getInstance().then((pref) {
          pref.setBool("isTokenExist", true);
          print("token stored");
        });
        //Navigator.pop(context);
        loginInto();
      }
    } else {
      Navigator.pop(context);
      print("token not stored");
      messageDialog(ERROR, response.body.toString());
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => TabsScreen())
      // );
    }
    // }).catchError((e) {
    //   Navigator.pop(context);
    //   print("token not accessed");
    //   messageDialog(ERROR, UNABLE_TO_SAVE_TOKEN_TO_SERVER);
    // });
    setState(() {
      token = "";
    });
  }

  loginInto() async {
    if (EmailValidator.validate(emailAddress) == false) {
      setState(() {
        isPhoneNumberError = true;
      });
    } else {
      dialog();
      //Toast.show("Logging in..", context, duration: 2);
      String url =
          "$SERVER_ADDRESS/api/doctorlogin?email=$emailAddress&password=$pass&token=$token";
      var response = await post(url, body: {
        'email': emailAddress,
        'password': pass,
        'token': "0",
      }).catchError((e) {
        Navigator.pop(context);
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      });
      try {
        print(response.statusCode);
        print(response.body);
        var jsonResponse = await jsonDecode(response.body);
        if (jsonResponse['success'].toString() == "0") {
          setState(() {
            Navigator.pop(context);
            isPasswordError = true;
            passErrorText = EITHER_MOBILE_NUMBER_OR_PASSWORD_IS_INCORRECT;
          });
        } else {
          await SharedPreferences.getInstance().then((pref) {
            pref.setBool("isLoggedInAsDoctor", true);
            pref.setString(
                "userId", jsonResponse['register']['doctor_id'].toString());
            pref.setString("name", jsonResponse['register']['name']);
            pref.setString(
                "phone",
                jsonResponse['register']['phone'] == null
                    ? ""
                    : jsonResponse['register']['phone'].toString());
            pref.setString("email", jsonResponse['register']['email']);
            pref.setString("token", token.toString());
          });
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DoctorTabsScreen()));
        }
      } catch (e) {
        Navigator.pop(context);
        messageDialog(ERROR, UNABLE_TO_LOAD_DATA_FORM_SERVER);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        isTokenPresent = pref.getBool("isTokenExist") ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  loginForm(),
                ],
              ),
            ),
            header(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Stack(
      children: [
        Image.asset(
          "assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(
                width: 15,
              ),
              // InkWell(
              //   onTap: (){
              //     Navigator.pop(context);
              //   },
              //   child: Image.asset("assets/moreScreenImages/back.png",
              //     height: 25,
              //     width: 22,
              //   ),
              // ),
              // SizedBox(width: 10,),
              Text(
                DOCTOR_LOGIN,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: WHITE, fontSize: 22),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bottom() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DO_NOT_HAVE_AN_ACCOUNT,
              style: GoogleFonts.poppins(
                color: BLACK,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterAsDoctor()));
              },
              child: Text(
                " $REGISTER_NOW",
                style: GoogleFonts.poppins(
                  color: AMBER,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget loginForm() {
    return Container(
      decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
      height: MediaQuery.of(context).size.height - 100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            //SizedBox(height: 10,),
            Image.asset(
              "assets/loginScreenImages/login_doctor.png",
              height: 180,
              width: 180,
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: ENTER_YOUR_EMAIL,
                  labelStyle: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT, fontWeight: FontWeight.w400),
                  errorText:
                      isPhoneNumberError ? ENTER_VALID_EMAIL_ADDRESS : null,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                    color: LIGHT_GREY_TEXT,
                  ))),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              onChanged: (val) {
                setState(() {
                  emailAddress = val;
                  isPhoneNumberError = false;
                  isPasswordError = false;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: PASSWORD,
                labelStyle: GoogleFonts.poppins(
                    color: LIGHT_GREY_TEXT, fontWeight: FontWeight.w400),
                errorText: isPasswordError ? passErrorText : null,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                  color: LIGHT_GREY_TEXT,
                )),
              ),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              onChanged: (val) {
                setState(() {
                  pass = val;
                  isPasswordError = false;
                });
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPassword("2")));
                  },
                  child: Text(
                    FORGET_PASSWORD,
                    style: TextStyle(
                        color: BLACK,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     InkWell(
            //       child: Text("Forget password ?",
            //         style: GoogleFonts.comfortaa(
            //             color: Colors.black,
            //             fontSize: 13,
            //             fontWeight: FontWeight.w900
            //         ),
            //       ),
            //       onTap: (){
            //         // Navigator.push(context,
            //         //   MaterialPageRoute(
            //         //     builder: (context) => ForgetPassword(),
            //         //   ),
            //         // );
            //       },
            //     ),
            //   ],
            // ),
            SizedBox(height: 20),
            Container(
              height: 50,
              //width: MediaQuery.of(context).size.width,
              child: InkWell(
                onTap: () {
                  isTokenPresent ? loginInto() : storeToken();
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(
                        "assets/moreScreenImages/header_bg.png",
                        height: 50,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Center(
                      child: Text(
                        LOGIN,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: WHITE,
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            bottom(),
          ],
        ),
      ),
    );
  }

  dialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              LOGGING_IN,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      PLEASE_WAIT_LOGGING_IN,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  messageDialog(String s1, String s2) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              s1,
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s2,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                )
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Theme.of(context).accentColor,
                child: Text(
                  OK,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: BLACK,
                  ),
                ),
              ),
            ],
          );
        });
  }
}
