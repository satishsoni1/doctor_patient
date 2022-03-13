import 'package:flutter/widgets.dart';
import 'package:book_appointment/PaymentGateways/MyBrainTree.dart';
import 'package:book_appointment/PaymentGateways/MyCardDetails.dart';
import 'package:book_appointment/views/Doctor/DoctorProfileSteps/add_holiday.dart';
import 'package:book_appointment/views/Doctor/DoctorProfileSteps/holiday_list.dart';
import 'package:book_appointment/views/Doctor/loginAsDoctor.dart';
import 'package:book_appointment/views/HomeScreen.dart';
import 'package:book_appointment/views/MoreScreen.dart';
import 'package:book_appointment/views/SplashScreen.dart';
import 'package:book_appointment/views/UserPastAppointments.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:book_appointment/CustomAds.dart';
//import 'package:firebase_core/firebase_core.dart' as fc;
//import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'en.dart';

const String SERVER_ADDRESS = "https://demo.freaktemplate.com/bookappointment";
// const String SERVER_ADDRESS = "";

const LANGUAGE = "en";
int PHONE_NUMBER_LENGTH = 10;
const String ADMOB_ID = "ca-app-pub-7803172892594923/5172476997";
//const String FACEBOOK_AD_ID = "727786934549239_727793487881917";

const bool ENABLE_ADS = false;
//true -> enable
//false -> disable

const int AD_TYPE = 1;
//0 -> facebook // not working in ios that's why we removed it
//1 -> admob

int LANGUAGE_TYPE = 0;
//0 ---> English
//1 ---> Arabic

///CURRENCY AND CURRENCY CODE
String CURRENCY = "\₹";
String CURRENCY_CODE = "INR";

Color WHITE = Colors.white;
Color BLACK = Colors.black;
Color LIGHT_GREY_SCREEN_BACKGROUND = Colors.grey.shade200;
Color LIGHT_GREY_TEXT = Colors.grey.shade500;
Color AMBER = Colors.amber.shade700;
String STRIPE_KEY = "pk_test_yFUNiYsEESF7QBY0jcZoYK9j00yHumvXho";
String TOKENIZATION_KEY = "sandbox_bn2rby52_8x2htw9jqj88wsyf";
//final nativeAdController = NativeAdmobController();
String LANGUAGE_FILE = "en";
// CustomAds customAds = CustomAds();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await fc.Firebase.initializeApp(
  //   options: FirebaseOptions(
  //     apiKey: "AIzaSyDbtUskocn1HhtjtbBItgECBlVnK3cXT_k",
  //     appId: "1:685265659495:android:cef754d9433325e72496c2",
  //     messagingSenderId: "685265659495",
  //     projectId: "goldsmith-63175",
  //   ),
  // );

  // await MobileAds.initialize();
  // This is my device id. Ad yours here
  // MobileAds.setTestDeviceIds(['9345804C1E5B8F0871DFE29CA0758842']);
  runApp(
    MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        timePickerTheme: TimePickerThemeData(
          dayPeriodTextColor: Color(0xFF0077FF),
          //hourMinuteColor: Colors.cyanAccent.shade700,
          helpTextStyle: GoogleFonts.poppins(),
        ),
        accentColor: Color(0xFF0077FF),
        primaryColor: Color(0xFF0077FF),
        backgroundColor: Colors.white,
        primaryColorDark: Colors.grey.shade700,
        primaryColorLight: Colors.grey.shade200,
        //highlightColor: Colors.amber.shade700,
        textTheme: TextTheme(
          headline1: GoogleFonts.poppins(),
          headline2: GoogleFonts.poppins(),
          headline3: GoogleFonts.poppins(),
          headline4: GoogleFonts.poppins(),
          headline5: GoogleFonts.poppins(),
          headline6: GoogleFonts.poppins(),
          subtitle1: GoogleFonts.poppins(),
          subtitle2: GoogleFonts.poppins(),
          caption: GoogleFonts.poppins(
            fontSize: 10,
          ),
          bodyText1:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          bodyText2:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w300),
          button: GoogleFonts.poppins(),
        ),
      ),
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('he', ''), // Hebrew, no country code
        const Locale('ar', ''), // Hebrew, no country code
        const Locale.fromSubtags(
            languageCode: 'zh'), // Chinese *See Advanced Locales below*
        // ... other locales the app supports
      ],
    ),
  );
}

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Widget> screens = [
    HomeScreen(),
    UserPastAppointments(),
    LoginAsDoctor(),
    MoreScreen()
  ];

  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // nativeAdController.setNonPersonalizedAds(true);
    // nativeAdController.setTestDeviceIds(["0B43A6DF92B4C06E3D9DBF00BA6DA410"]);
    // nativeAdController.stateChanged.listen((event) {
    //   print(event);
    // });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double top;
    double bottom;
    //width = width > 563 ? 563 : width;
    if (width > 449) {
      width = 449;
      top = 60.0;
      bottom = 60.0;
    } else {
      top = 0;
      bottom = 0;
    }
    //width = 460;
    //height = height > 667 ? 667 : height;
    //height = height;
    print(width);

    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Scaffold(
            body: screens[index],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                //borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        index == 0
                            ? "assets/homeScreenImages/home_active.png"
                            : "assets/homeScreenImages/home_unactive.png",
                        height: 25,
                        width: 25,
                      ),
                      label: HOME,
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        index == 1
                            ? "assets/homeScreenImages/appointment_active.png"
                            : "assets/homeScreenImages/appointment_unactive.png",
                        height: 25,
                        width: 25,
                        fit: BoxFit.cover,
                      ),
                      label: APPOINTMENT,
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        index == 2
                            ? "assets/homeScreenImages/d_l_active.png"
                            : "assets/homeScreenImages/d_l_unactive.png",
                        height: 25,
                        width: 25,
                        fit: BoxFit.cover,
                      ),
                      label: DOCTOR_LOGIN,
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        index == 3
                            ? "assets/homeScreenImages/more_active.png"
                            : "assets/homeScreenImages/more_unactive.png",
                        height: 25,
                        width: 25,
                        fit: BoxFit.cover,
                      ),
                      label: MORE,
                    ),
                  ],
                  selectedLabelStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 8,
                  ),
                  type: BottomNavigationBarType.fixed,
                  unselectedLabelStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 7,
                  ),
                  unselectedItemColor: Colors.grey.shade500,
                  selectedItemColor: Colors.black,
                  onTap: (i) {
                    setState(() {
                      index = i;
                    });
                  },
                  currentIndex: index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
