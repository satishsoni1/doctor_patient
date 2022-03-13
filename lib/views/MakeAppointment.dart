import 'dart:convert';

import 'package:book_appointment/PaymentGateways/MyBrainTreeUtils.dart';
import 'package:book_appointment/PaymentGateways/MyCardDetails.dart';
import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/modals/MakeAppointmentClass.dart';
import 'package:book_appointment/views/HomeScreen.dart';
import 'package:book_appointment/views/ProfilePage.dart';
import 'package:book_appointment/views/UserAppointmentDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class MakeAppointment extends StatefulWidget {
  String id;
  String name;
  String consultationFee;

  MakeAppointment(this.id, this.name, this.consultationFee);

  @override
  _MakeAppointmentState createState() => _MakeAppointmentState();
}

class _MakeAppointmentState extends State<MakeAppointment> {

  DateTime dateTime = DateTime.now();
  MakeAppointmentClass makeAppointmentClass;
  bool isLoading = true;
  bool istimingSlotLoading = true;
  bool isNoSlot = false;
  bool isNoTimingSlot = false;
  String description = "";
  String userId = "";
  String doctorId = "";
  String date = "";
  String slotId = "";
  String slotName = "";
  bool isPhoneError = false;
  ScrollController scrollController = ScrollController();
  bool isAppointmentMadeSuccessfully = false;
  String AppointmentId = "";
  TextEditingController textEditingController = TextEditingController();

  List<String> days = [
    SUNDAY,
    MONDAY,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY,
    SUNDAY,
  ];

  List<String> months = [
    JANUARY,
    FEBRUARY,
    MARCH,
    APRIL,
    MAY,
    JUNE,
    JULY,
    AUGUST,
    SEPTEMBER,
    OCTOBER,
    NOVEMBER,
    DECEMBER,
  ];

  List<bool> isSelected = [];
  List<bool> selectedSlot = [];
  List<bool> selectedTimingSlot = [];
  int previousSelectedIndex = 0;
  int previousSelectedSlot = 0;
  int previousSelectedTimingSlot = 0;
  int currentSlotsIndex = 0;
  bool isDescriptionEmpty = false;
  Future<bool> checkHolidayFuture;


  @override
  void initState() {
    super.initState();
    initialize();
    setState(() {
      date = dateTime.toString().substring(0,10);
    });
  }

  initialize(){

    for(int i=0; i<30; i++){
      isSelected.add(false);
    }
    setState(() {
      isSelected[0]=true;
    });
    SharedPreferences.getInstance().then((pref){
      setState(() {
        textEditingController.text = pref.getString("phone");
        userId = pref.getString("userId");
        doctorId = widget.id;
        checkHolidayFuture = checkIfHoliday(date);
      });
      getSlots(dateTime.toString().substring(0,10));
    });
  }

  getSlots(String dateinside) async{
    setState(() {
      selectedSlot.clear();
      isLoading = true;
      isNoSlot = false;
      slotName = "";
      slotId = "";
      currentSlotsIndex = 0;
      previousSelectedTimingSlot = 0;
    });

    final response = await get("$SERVER_ADDRESS/api/getslot?doctor_id=${widget.id}&date=$dateinside");

    print(response.request);
    print(response.body);

    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      makeAppointmentClass = MakeAppointmentClass.fromJson(jsonResponse);
      if(makeAppointmentClass.success.toString() == "1"){
        for(int i=0; i<makeAppointmentClass.data.length; i++){
          setState(() {
            selectedSlot.add(false);
          });
        }
        initializeTimeSlots(0);
        setState(() {
          isLoading = false;
          selectedSlot[0] = true;
          previousSelectedSlot = 0;
        });
      }
      else{
        setState(() {
          isNoSlot = true;
          isLoading = false;
        });
      }
    }
  }

  initializeTimeSlots(int index){
    setState(() {
      selectedTimingSlot.clear();
    });
    for(int i=0; i<makeAppointmentClass.data[index].slottime.length; i++){
      setState(() {
        selectedTimingSlot.add(false);
      });
    }
    setState(() {
      currentSlotsIndex = index;
      //timingSlotsList(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        body: Stack(
          children: [
            button(),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 80),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    header(),
                    dayDateList(),
                    !isLoading
                        ? isNoSlot ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          NO_SLOT_AVAILABLE,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: LIGHT_GREY_TEXT,
                              fontSize: 15
                          ),
                        ),
                      ),
                    ) : slotsList()
                        : Center(child: CircularProgressIndicator(),),
                    //!isLoading ? timingSlotsList() : Container(),
                    SizedBox(height: 80,),
                  ],
                ),
              ),
            ),
            header(),
          ],
        ),
      ),
    );
  }

  Widget header(){
    return Stack(
      children: [
        Image.asset("assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 15,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                widget.name,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: WHITE,
                    fontSize: 22
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget dayDateList(){
    return Container(
      height: 130,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: ListView.builder(
        shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 30,
          itemBuilder: (context, index){
            return dayDateCard(index);
          }),
    );
  }

  Widget dayDateCard(int i) {
    return InkWell(
      onTap: (){
        setState(() {
          // selectedSlot[previousSelectedSlot] = false;
          isSelected[previousSelectedIndex] = false;
          isSelected[i] = !isSelected[i];
          previousSelectedIndex = i;
          date = dateTime.add(Duration(days: i)).toString().substring(0,10);
          checkHolidayFuture = checkIfHoliday(date);
          print(date);
          getSlots(dateTime.add(Duration(days: i)).toString().substring(0,10));
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        //height: 90,
        margin: EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
            color: isSelected[i] ? AMBER : WHITE,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(days[dateTime.add(Duration(days: i)).weekday],
              //days[dateTime.weekday+i < 6 ? dateTime.weekday : i],
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isSelected[i] ? WHITE : BLACK,
                  fontSize: 10
              ),
            ),
            Text(
              dateTime.add(Duration(days: i)).day.toString(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isSelected[i] ? WHITE : LIGHT_GREY_TEXT,
                  fontSize: 20
              ),
            ),
            Container(
              width: 50,
              child: Divider(
                color: isSelected[i] ? WHITE : LIGHT_GREY_TEXT,
                height: 20,
              ),
            ),
            Text(
              months[dateTime.add(Duration(days: i)).month - 1].toString()+", "+dateTime.add(Duration(days: i)).year.toString(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: isSelected[i] ? WHITE : LIGHT_GREY_TEXT,
                  fontSize: 10
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget slotsList(){
    return FutureBuilder<bool>(
      future: checkHolidayFuture,
        builder: (context, snapshot){
          if(snapshot.hasData){
            if(!snapshot.data) {
              return Column(
                children: [
                  Container(
                    height: 100,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: makeAppointmentClass.data.length,
                        itemBuilder: (context, index) {
                          return slots(index);
                        }),
                  ),
                  timingSlotsList(currentSlotsIndex),
                  fillUpForm(),
                ],
              );
            }else{
              return Column(
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  Text(
                    DOCTOR_ON_LEAVE,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      DOCTOR_ON_LEAVE_DESC(date),
                      style: TextStyle(
                        color: LIGHT_GREY_TEXT,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
          }else if(snapshot.hasError){
            return Center(
              child: Text(
                snapshot.error.toString()
              ),
            );
          }else{
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
        },
    );
  }

  Widget slots(int i) {
    return InkWell(
      onTap: (){
        setState(() {
          selectedSlot[previousSelectedSlot] = false;
          selectedSlot[i] = !selectedSlot[i];
          previousSelectedSlot = i;
          initializeTimeSlots(i);
          print("slots $i");
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 90,
        margin: EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
            color: selectedSlot[i] ? AMBER : WHITE,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10,),
            Container(
              height: 45,
              width: 45,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedSlot[i] ? WHITE : LIGHT_GREY_SCREEN_BACKGROUND,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Image.asset(
                    selectedSlot[i]
                        ? "assets/makeAppointmentScreenImages/day_active.png"
                        : "assets/makeAppointmentScreenImages/day_unactive.png",
                ),
              ),
            ),
            SizedBox(width: 10,),
            Text(makeAppointmentClass.data[i].title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: selectedSlot[i] ? WHITE : BLACK,
                  fontSize: 14
              ),
            ),
            SizedBox(width: 15,),
          ],
        ),
      ),
    );
  }
  
  Widget timingSlotsList(int index){
    print(index);
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 1.8,
      physics: ClampingScrollPhysics(),
      children: List.generate(makeAppointmentClass.data[index].slottime.length, (ind) => timingSlotsCard(ind, makeAppointmentClass.data[index].slottime)),
    );
  }

  Widget timingSlotsCard(int i,List<Slottime> list) {
    return InkWell(
      onTap: (){
        setState(() {
          print(list[i].id);
          if(list[i].isBook == "1"){
            Toast.show(NO_SLOT_AVAILABLE, context, duration: 2);
          }else {
            slotId = list[i].id.toString();
            slotName = list[i].name;
            print("previousSelectedTimingSlot : " + (previousSelectedTimingSlot > list.length ? 0 : previousSelectedTimingSlot).toString());
            selectedTimingSlot[previousSelectedTimingSlot > list.length ? 0 : previousSelectedTimingSlot] = false;
            selectedTimingSlot[i] = !selectedTimingSlot[i];
            previousSelectedTimingSlot = i;
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 90,
        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
        decoration: BoxDecoration(
            color: list[i].isBook == "1" ? Colors.grey.withOpacity(0.1) : selectedTimingSlot[i] ? AMBER: WHITE,
            borderRadius: BorderRadius.circular(15)
        ),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              list[i].isBook == "1"
                  ? "assets/makeAppointmentScreenImages/time_unactive.png"
                  : selectedTimingSlot[i]
                    ? "assets/makeAppointmentScreenImages/time_active.png"
                    : "assets/makeAppointmentScreenImages/time_unactive.png",
              height: 15,
              width: 15,
            ),
            SizedBox(width: 10,),
            Text(list[i].name,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color:
                  list[i].isBook == "0"
                      ? selectedTimingSlot[i] ? WHITE : BLACK
                      : Colors.grey.withOpacity(0.5),
                  fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  fillUpForm(){
    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.phone,
            controller: textEditingController,
            onChanged: (val){
              setState(() {
                isPhoneError = false;
              });
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              labelText: PHONE_NUMBER,
              errorText: isPhoneError ? ENTER_VALID_MOBILE_NUMBER : null,
              labelStyle: Theme.of(context).textTheme.bodyText2.apply(
                fontSizeDelta: 3,
                fontWeightDelta: 2,
                color: Theme.of(context).primaryColorDark
              ),
            ),
            style: Theme.of(context).textTheme.bodyText1.apply(
                fontSizeDelta: 3,
                //color: Theme.of(context).primaryColorDark
            ),
          ),
          SizedBox(height: 10,),
          TextField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColorDark)
              ),
              labelText: DESCRIPTION,
              errorText: isDescriptionEmpty ? THIS_FIELD_IS_REQUIRED : null,
              labelStyle: Theme.of(context).textTheme.bodyText2.apply(
                fontSizeDelta: 3,
                fontWeightDelta: 2,
                color: Theme.of(context).primaryColorDark
              ),
            ),
            style: Theme.of(context).textTheme.bodyText1.apply(
                fontSizeDelta: 3,
                //color: Theme.of(context).primaryColorDark
            ),
            onChanged: (val){
              setState(() {
                isDescriptionEmpty = false;
                description = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 50,
        margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            //print(date);
            //bookAppointment();
            processPayment();
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset("assets/moreScreenImages/header_bg.png",
                  height: 50,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Center(
                child: Text(
                  MAKE_AN_APPOINTMENT,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: WHITE,
                      fontSize: 18
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  processPayment() async{
    //print("Fee : ${int.parse(widget.consultationFee)}");
    if(textEditingController.text == null || textEditingController.text.isEmpty || textEditingController.text.length < PHONE_NUMBER_LENGTH){
      setState(() {
        isPhoneError = true;
      });
    }else if(slotId == null || slotId.length == 0){
      messageDialog(ERROR, PLEASE_SELECT_APPOINTMENT_TIME);
    } else if(description.isEmpty){
      setState(() {
        isDescriptionEmpty = true;
        scrollController.animateTo(400,duration: Duration(milliseconds: 500),curve: Curves.easeIn);
      });
    }else {
      bottomSheet();
      // messageDialogPayment(PROCESS_PAYMENT,
      //     YOU_WILL_CHARGED_CONSULTAION_FEE_OF +
      //         CURRENCY + (widget.consultationFee ?? "0")+ ". " +
      //         ARE_YOU_SURE_TO_CONTINUE);
    }
  }

  bookAppointment({String nonce, String type}) async{
      dialog();
      print("user_id : " + userId +
          "\ndoctor_id : " + doctorId);
      String url = "$SERVER_ADDRESS/api/bookappointment";
      final response = await post(url, body: {
        "user_id": userId,
        "doctor_id": doctorId,
        "date": date,
        "slot_id": slotId,
        "slot_name": slotName,
        "consultation_fees" : widget.consultationFee ?? "0",
        "payment_method_nonce" : type == "1" ? (nonce ?? "") : "",
        "stripeToken" : type == "2" ? (nonce ?? "") : "",
        "payment_type" : type,
        "phone": textEditingController.text,
        "user_description": description,
      });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if (jsonResponse["success"].toString() == "1") {
          Navigator.pop(context);
          setState(() {
            isAppointmentMadeSuccessfully = true;
            AppointmentId = jsonResponse['data'].toString();
          });
          messageDialog(SUCCESSFUL, APPOINTMENT_MADE_SUCCESSFULLY);
          print(jsonResponse);
        } else {
          Navigator.pop(context);
          messageDialog(ERROR, jsonResponse['register']);
        }
      }

  }

  Future<bool> checkIfHoliday(String date) async{

    bool isHoliday;

    var request = http.Request('GET', Uri.parse('$SERVER_ADDRESS/api/checkholiday?doctor_id=$doctorId&date=$date'));

    print(request.url);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      print(response.request);
      print(jsonResponse);
      isHoliday = jsonResponse['success'].toString() == '0' ? true : false;
    }

    return isHoliday;

  }

  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(PROCESSING,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(PLEASE_WAIT_WHILE_MAKING_APPOINTMENT,
                      style: GoogleFonts.poppins(
                          fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: GoogleFonts.poppins(
                  fontSize: 14,
                ),)
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () async{
                  if(isAppointmentMadeSuccessfully){
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => TabsScreen(),
                    ));
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UserAppointmentDetails(AppointmentId),
                    ));
                  }else{
                    Navigator.pop(context);
                  }
                },
                color: Theme.of(context).primaryColor,
                child: Text(OK,style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: BLACK,
                ),),
              ),
            ],
          );
        }
    );
  }

  messageDialogPayment(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1, style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: Theme.of(context).textTheme.bodyText1,)
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () async{
                    Navigator.pop(context);
                  },
                  color: WHITE,
                  child: Text(WAIT,style: Theme.of(context).textTheme.bodyText1)
              ),
              FlatButton(
                  onPressed: () async{
                    Navigator.pop(context);

                  },
                  color: Theme.of(context).primaryColor,
                  child: Text(YES,style: Theme.of(context).textTheme.bodyText1)
              ),
            ],
          );
        }
    );
  }

  int selectedPaymentMethod = 2;

  bottomSheet(){
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      builder: (context){
        return StatefulBuilder(
            builder: (context, setState){
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: WHITE,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 15,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.name + "'s " + CONSULTATION_FEE,
                                  style: TextStyle(
                                      color: BLACK,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Text(
                                CURRENCY.trim() + (widget.consultationFee ?? "0"),
                                style: GoogleFonts.ubuntu(
                                    color: AMBER,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold
                                ),
                              )

                            ],
                          ),
                        ),
                        SizedBox(height: 5,),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.7,
                        ),
                        SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            SELECT_A_PAYMENT_METHOD.toUpperCase(),
                            style: TextStyle(
                              color: LIGHT_GREY_TEXT,
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        paymentMethodCardTile(title: CASH_ON_BOARD, explanation: PAY_ON_VISTING_DOCTOR, index: 2, setState: setState),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.7,
                        ),
                        paymentMethodCardTile(title: BRAINTREE, explanation: BRAINTREE_EXPLANATION, index: 0, setState: setState),
                        Divider(
                          color: Colors.grey,
                          thickness: 0.7,
                        ),
                        paymentMethodCardTile(title: STRIPE, explanation: STRIPE_EXPLANATION, index: 1, setState: setState),

                        SizedBox(height: 10,),
                      ],
                    ),
                  ),

                  Container(
                    height: 50,
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    //width: MediaQuery.of(context).size.width,
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                        if(selectedPaymentMethod == 0){
                          processBrainTreePaymentAndBookAppointment();
                        }else if(selectedPaymentMethod == 1){
                          processStripePaymentAndBookAppointment();
                        }else{
                          bookAppointment(type: "cod");
                        }
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset("assets/moreScreenImages/header_bg.png",
                              height: 50,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          Center(
                            child: Text(
                              selectedPaymentMethod == 2 ? MAKE_AN_APPOINTMENT : PROCESS_PAYMENT,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: WHITE,
                                  fontSize: 18
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            });
      }
    );
  }
  
  paymentMethodCardTile({String title, String explanation, int index, StateSetter setState}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: (){
        setState(() {
          selectedPaymentMethod = index;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 5),
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(color: LIGHT_GREY_TEXT),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selectedPaymentMethod == index ? AMBER : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          // ClipRRect(
          //     borderRadius: BorderRadius.circular(5),
          //     child: Image.asset("assets/makeAppointmentScreenImages/brain_tree.png", height: 30, width: 50, fit: BoxFit.fill,)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),),
                Text(explanation, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: LIGHT_GREY_TEXT),)
              ],
            ),
          )
        ],
      ),
    ),
  );

  processBrainTreePaymentAndBookAppointment() async{
    var request = BraintreeDropInRequest(
      tokenizationKey: TOKENIZATION_KEY,
      collectDeviceData: true,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: widget.consultationFee.toString(),
        currencyCode: CURRENCY_CODE,
        billingAddressRequired: false,
      ),
      paypalRequest: BraintreePayPalRequest(
        amount: widget.consultationFee.toString(),
        displayName: widget.name + "'s $CONSULTATION_FEE",
      ),
      cardEnabled: true,
    );
    final result = await BraintreeDropIn.start(request);
    if (result != null) {
      bookAppointment(nonce: result.paymentMethodNonce.nonce, type: "1");
    }
  }

  processStripePaymentAndBookAppointment() async{
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyCardDetails(true)));
    await Future.delayed(Duration(seconds: 2));
    String token = await Navigator.push(context, MaterialPageRoute(builder: (context) => MyCardDetails(false)));
    if(token != null){
      bookAppointment(nonce: token, type: "2");
    }
  }

}
