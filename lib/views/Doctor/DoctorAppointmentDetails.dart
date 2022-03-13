import 'dart:convert';
import 'dart:io';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/modals/DoctorAppointmentDetailsClass.dart';
import 'package:book_appointment/views/my_photo_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorAppointmentDetails extends StatefulWidget {

  String id;
  DoctorAppointmentDetails(this.id);

  @override
  _DoctorAppointmentDetailsState createState() => _DoctorAppointmentDetailsState();
}

class _DoctorAppointmentDetailsState extends State<DoctorAppointmentDetails> {

  DoctorAppointmentDetailsClass doctorAppointmentDetailsClass;
  Future getAppointmentDetails;
  bool areChangesMade = false;
  bool isCompleteError = false;
  File _image;
  final picker = ImagePicker();



  fetchAppointmentDetails() async{
    print(widget.id);
    final response = await get("$SERVER_ADDRESS/api/appointmentdetail?id=${widget.id}&type=2");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      print(response.request);
      print(response.body);
      if(jsonResponse["success"].toString() == "1"){
        setState(() {
          doctorAppointmentDetailsClass = DoctorAppointmentDetailsClass.fromJson(jsonResponse);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.id);
    getAppointmentDetails = fetchAppointmentDetails();
  }

  Future<bool> _willPopScope() async {
    Navigator.pop(context, areChangesMade);
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
          onWillPop: _willPopScope,
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColorLight,
            appBar: AppBar(
              flexibleSpace: header(),
              leading: Container(),
            ),
            body: FutureBuilder(
              future: getAppointmentDetails,
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: CircularProgressIndicator()));
                }else{
                  return Stack(
                    children: [
                      appointmentListWidget(doctorAppointmentDetailsClass.data),
                      button(),
                    ],
                  );
                }
              },
            ),
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
                  APPOINTMENT,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  ),
                  //style: Theme.of(context).textTheme.headline5.apply(color: Theme.of(context).backgroundColor)
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget appointmentListWidget(Data list) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: Uri.encodeFull(list.image) ?? " ",
                        height: 75,
                        width: 75,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).primaryColorLight,
                          child: Center(
                            child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                          ),

                        ),
                        errorWidget: (context,url,err) => Container(
                          color: Theme.of(context).primaryColorLight,
                          child: Center(
                            child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(list.name,
                                  style: Theme.of(context).textTheme.bodyText2.apply(
                                      fontWeightDelta: 5,
                                    fontSizeDelta: 2
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context).primaryColorLight
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/detailScreenImages/time.png",
                                  height: 13,
                                  width: 13,
                                ),
                                SizedBox(width: 5,),
                                Text(statusToString(list.status), style: Theme.of(context).textTheme.caption.apply(
                                  fontSizeDelta: 0.5,
                                  fontWeightDelta: 2,
                                ),),
                                SizedBox(width: 5,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          "assets/homeScreenImages/calender.png",
                          height: 17,
                          width: 17,
                        ),
                        SizedBox(height: 5,),
                        Text(
                            list.date.toString().substring(8)+"-"+list.date.toString().substring(5,7)+"-"+list.date.toString().substring(0,4),
                            style: Theme.of(context).textTheme.caption
                        ),
                        Text(list.slot,
                            style: Theme.of(context).textTheme.bodyText1.apply(
                                fontWeightDelta: 2
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  padding: EdgeInsets.all(8),
                  color: Theme.of(context).backgroundColor,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(PHONE_NUMBER,
                                  style: Theme.of(context).textTheme.bodyText1.apply(
                                    fontWeightDelta: 1,
                                    fontSizeDelta: 1.5
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(list.phone,
                                  style: Theme.of(context).textTheme.caption.apply(
                                    fontWeightDelta: 2,
                                    color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: (){
                                launch("tel:"+list.phone);
                              },
                              child: Image.asset(
                                  "assets/detailScreenImages/phone_button.png",
                                height: 45,
                                width: 45,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(EMAIL_ADDRESS,
                                  style: Theme.of(context).textTheme.bodyText1.apply(
                                    fontWeightDelta: 1,
                                    fontSizeDelta: 1.5
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(list.email,
                                  style: Theme.of(context).textTheme.caption.apply(
                                    fontWeightDelta: 2,
                                    color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: (){
                                print("pressed");
                                launch(Uri(
                                  scheme: 'mailto',
                                  path: list.email,
                                  // queryParameters: {
                                  //   'subject': 'Example Subject & Symbols are allowed!'
                                  // }
                                ).toString());
                              },
                              child: Image.asset(
                                  "assets/detailScreenImages/email_btn.png",
                                height: 45,
                                width: 45,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(DESCRIPTION,
                                  style: Theme.of(context).textTheme.bodyText1.apply(
                                    fontWeightDelta: 1,
                                    fontSizeDelta: 1.5
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  width: 300,
                                  child: Text(list.description,
                                    style: Theme.of(context).textTheme.caption.apply(
                                      fontWeightDelta: 2,
                                      color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 15,),
                        list.prescription.isNotEmpty ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(PRESCRIPTION,
                              style: Theme.of(context).textTheme.bodyText1.apply(
                                  fontWeightDelta: 1,
                                  fontSizeDelta: 1.5
                              ),
                            ),
                            SizedBox(height: 5,),
                             Stack(
                               children: [
                                 ClipRRect(
                                   borderRadius: BorderRadius.circular(15),
                                   child: InkWell(
                                     onTap: (){
                                       Navigator.push(context, MaterialPageRoute(builder: (context) => MyPhotoView(imagePath: list.prescription)));
                                     },
                                     child: CachedNetworkImage(
                                        imageUrl: list.prescription,
                                       errorWidget: (context, rsn, err){
                                          return Center(
                                            child: Text(
                                              rsn.toString(),
                                              style: TextStyle(
                                                color: Colors.black
                                              ),
                                            ),
                                          );
                                       },
                                       height: 200,
                                       width: double.maxFinite,
                                       fit: BoxFit.cover,
                            ),
                                   ),
                                 ),
                                 Positioned.fill(child: Padding(
                                   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                   child: Align(
                                     alignment: Alignment.bottomRight,
                                     child: Container(
                                       height: 50,
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: Colors.amber,
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [
                                           IconButton(
                                             onPressed: () async{
                                               print(list.prescription);
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPhotoView(imagePath: list.prescription)));
                                             },
                                             icon: Icon(Icons.open_in_full, color: Colors.white,),
                                             iconSize: 20,
                                             constraints: BoxConstraints(
                                                 maxHeight: 40,
                                                 maxWidth: 40
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ),
                                 ))
                               ],
                             ),
                          ],
                        ) : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        button(),
      ],
    );
  }

  String statusToString(int status) {
    switch (status){
      case 0:
        return ABSENT;
      case 1:
        return RECEIVED;
      case 2:
        return APPROVED;
      case 3:
        return IN_PROCESS;
      case 4:
        return COMPLETED;
      case 5:
        return REJECTED;
    }

  }



  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: doctorAppointmentDetailsClass.data.status == 1
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: InkWell(
              onTap: (){
                changeStatus("3");
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
                      ACCEPT,
                      style: Theme.of(context).textTheme.bodyText1.apply(
                        color: Theme.of(context).backgroundColor,
                        fontSizeDelta: 2
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: (){
                changeStatus("5");
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
                        CANCEL,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          color: Theme.of(context).backgroundColor,
                          fontSizeDelta: 2
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      )
          : doctorAppointmentDetailsClass.data.status == 3
              ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
            child: InkWell(
              onTap: (){
                if(doctorAppointmentDetailsClass.data.date == DateTime.now().toString().substring(0,10)){
                  print("yes");
                  uploadPrescriptionAndChangeStatus("4");
                }else{
                  print("no");
                  setState(() {
                    isCompleteError = true;
                  });
                  messageDialog(ERROR, "Appointment is on ${doctorAppointmentDetailsClass.data.date}. You can't mark it as Completed today");
                }
                // print(doctorAppointmentDetailsClass.data.date);
                // print(DateTime.now().toString().substring(0,10));
                //changeStatus("4");
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
                        COMPLETE,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                            color: Theme.of(context).backgroundColor,
                            fontSizeDelta: 2
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          Container(
            height: 50,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: (){
                changeStatus("0");
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
                        ABSENT,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                            color: Theme.of(context).backgroundColor,
                            fontSizeDelta: 2
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ) : Container(),
    );
  }

  changeStatus(status) async{
    dialog();
    final response = await post("$SERVER_ADDRESS/api/appointmentstatuschange?app_id=${widget.id}&status=$status");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'].toString() == "1"){
        Navigator.pop(context);
        //messageDialog(SUCCESSFUL, jsonResponse['msg']);
        setState(() {
          getAppointmentDetails = fetchAppointmentDetails();
          areChangesMade = true;
        });
      }
    }
  }

  uploadPrescriptionAndChangeStatus(String status) async{
    await showUploadPrescriptionSheet();
    print('closed');


    // final response = await post("$SERVER_ADDRESS/api/appointmentstatuschange?app_id=${widget.id}&status=$status");
    // if(response.statusCode == 200){
    //   final jsonResponse = jsonDecode(response.body);
    //   if(jsonResponse['success'] == "1"){
    //     Navigator.pop(context);
    //     //messageDialog(SUCCESSFUL, jsonResponse['msg']);
    //     setState(() {
    //       getAppointmentDetails = fetchAppointmentDetails();
    //       areChangesMade = true;
    //     });
    //   }
    // }
  }

  uploadPrescription() async{
    dialog();

    var request = http.MultipartRequest('POST', Uri.parse('$SERVER_ADDRESS/api/appointmentstatuschange'));
    request.fields.addAll({
      'app_id': '${widget.id}',
      'status': '4'
    });
    request.files.add(await http.MultipartFile.fromPath('prescription', '${_image.path}'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(await response.stream.bytesToString());
      if(jsonResponse['success'].toString() == "1"){
        Navigator.pop(context);
        //messageDialog(SUCCESSFUL, jsonResponse['msg']);
        setState(() {
          getAppointmentDetails = fetchAppointmentDetails();
          areChangesMade = true;
        });
      }
    }
    else {
      messageDialog(ERROR, response.reasonPhrase);
      print(response.reasonPhrase);
    }
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
                    child: Text(PLEASE_WAIT_WHILE_PROCESSING,
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
                onPressed: (){
                  if(isCompleteError){
                    Navigator.pop(context);
                  }else {
                    setState(() {
                      getAppointmentDetails = fetchAppointmentDetails();
                    });
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


  double heightOfModalBottomSheet = 100;

  showUploadPrescriptionSheet(){
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context){
          return StatefulBuilder(
            builder: (context, setState){


              return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      UPLOAD_PRESCRIPTION,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      UPLOAD_PRESCRIPTION_DESC,
                      style: TextStyle(
                          color: LIGHT_GREY_TEXT,
                          fontSize: 12
                      ),
                    ),
                    SizedBox(height: 10,),

                    Stack(
                      children: [
                        _image == null
                            ? DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(12),
                          padding: EdgeInsets.all(6),
                          dashPattern: [5, 3, 5, 3],
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            child: InkWell(
                              onTap: () async{
                                final pickedFile = await picker.getImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 25
                                );

                                if (pickedFile != null) {
                                  setState(() {
                                    _image = File(pickedFile.path);
                                    print(_image.path);
                                  });
                                  // Navigator.pop(context);
                                } else {
                                  print('No image selected.');
                                }
                              },
                              child: Container(
                                height: 150,
                                width: double.maxFinite,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 50,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        'Choose from gallery',
                                        style: TextStyle(
                                            fontSize: 12
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image,
                            height: 180,
                            fit: BoxFit.cover,
                            width: double.maxFinite,
                          ),
                        ),
                        Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async{

                                              final pickedFile = await picker.getImage(
                                                  source: ImageSource.camera,
                                                  imageQuality: 25
                                              );

                                                if (pickedFile != null) {
                                                  setState(() {
                                                    _image = File(pickedFile.path);
                                                    print(_image.path);
                                                  });
                                                  // Navigator.pop(context);
                                                } else {
                                                  print('No image selected.');
                                                }

                                            },
                                            icon: Icon(Icons.camera_alt, color: Colors.white,),
                                            iconSize: 20,
                                            constraints: BoxConstraints(
                                              maxHeight: 40,
                                              maxWidth: 40
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _image == null
                                        ? SizedBox()
                                        : Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async{

                                              final pickedFile = await picker.getImage(
                                                  source: ImageSource.gallery,
                                                  imageQuality: 25
                                              );

                                              if (pickedFile != null) {
                                                setState(() {
                                                  _image = File(pickedFile.path);
                                                  print(_image.path);
                                                });
                                                // Navigator.pop(context);
                                              } else {
                                                print('No image selected.');
                                              }

                                            },
                                            icon: Icon(Icons.photo, color: Colors.white,),
                                            iconSize: 20,
                                            constraints: BoxConstraints(
                                                maxHeight: 40,
                                                maxWidth: 40
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _image == null
                                        ? SizedBox()
                                        : Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async{
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPhotoView(imagePath: _image.path, isFromFile: true,)));
                                            },
                                            icon: Icon(Icons.open_in_full, color: Colors.white,),
                                            iconSize: 20,
                                            constraints: BoxConstraints(
                                                maxHeight: 40,
                                                maxWidth: 40
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ),
                      ],
                    ),

                    SizedBox(height: 20,),

                    _image == null ? SizedBox() : Container(
                      height: 50,
                      child: InkWell(
                        onTap: (){
                          setState((){
                            _image = null;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: LIGHT_GREY_TEXT.withOpacity(0.2),
                              ),
                            ),
                            Center(
                              child: Text(
                                  REMOVE_PRESCRIPTION,
                                  style: Theme.of(context).textTheme.bodyText1.apply(
                                      color: Colors.black,
                                      fontSizeDelta: 2
                                  )
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    Container(
                      height: 50,
                      child: InkWell(
                        onTap: (){
                          if(_image != null){
                            Navigator.pop(context);
                            uploadPrescription();
                          }else {
                            Navigator.pop(context);
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
                                  _image != null ? UPLOAD_PRESCRIPTION : CANCEL,
                                  style: Theme.of(context).textTheme.bodyText1.apply(
                                      color: Theme.of(context).backgroundColor,
                                      fontSizeDelta: 2
                                  )
                              ),
                            )
                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              );
            },
          );
        },
    );
  }


  Future getImage(bool isFromGallery) async {
    final pickedFile = await picker.getImage(
        source: isFromGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 25
    );

    setState(() {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          print(_image.path);
        });
        // Navigator.pop(context);
      } else {
        print('No image selected.');
      }
    });
  }


}


