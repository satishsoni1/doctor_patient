import 'dart:convert';

import 'package:book_appointment/en.dart';
import 'package:book_appointment/main.dart';
import 'package:book_appointment/modals/UserAppointmentsClass.dart';
import 'package:cached_network_image/cached_network_image.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserAppointmentDetails.dart';

class AllAppointments extends StatefulWidget {
  UserAppointmentsClass userAppointmentsClass;

  AllAppointments(this.userAppointmentsClass);

  @override
  _AllAppointmentsState createState() => _AllAppointmentsState();
}

class _AllAppointmentsState extends State<AllAppointments> {
  List<AppointmentData> list = List();
  String userId;
  Future loadAppointments;
  bool isAppointmentExist = false;
  bool isLoadingMore = false;
  String nextUrl = "";
  UserAppointmentsClass userAppointmentsClass;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      setState(() {
        userId = pref.getString("userId") ?? "";
        print(userId);
        loadAppointments = fetchUpcomingAppointments();
      });
    });
    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //print("Loadmore");
        loadMore();
      }
    });
    //print(widget.userAppointmentsClass.data.length);
  }

  Widget _getAdContainer() {
    return Container(
        // height: 60,
        // margin: EdgeInsets.all(10),
        // child: NativeAdmob(
        //   // Your ad unit id
        //   adUnitID: ADMOB_ID,
        //   controller: nativeAdController,
        //   type: NativeAdmobType.banner,
        // ),
        );
  }

  fetchUpcomingAppointments() async {
    final response =
        await get("$SERVER_ADDRESS/api/usersuappointment?user_id=$userId");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'].toString() == "1") {
        setState(() {
          isAppointmentExist = true;
          userAppointmentsClass = UserAppointmentsClass.fromJson(jsonResponse);
          list.addAll(userAppointmentsClass.data.appointmentData);
          nextUrl = userAppointmentsClass.data.nextPageUrl;
        });
      } else {
        setState(() {
          isAppointmentExist = false;
        });
      }
    }
  }

  loadMore() async {
    if (nextUrl != "null") {
      final response = await get("$nextUrl&user_id=$userId");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'].toString() == "1") {
          setState(() {
            userAppointmentsClass =
                UserAppointmentsClass.fromJson(jsonResponse);
            list.addAll(userAppointmentsClass.data.appointmentData);
            nextUrl = userAppointmentsClass.data.nextPageUrl;
          });
        } else {
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
        backgroundColor: LIGHT_GREY_SCREEN_BACKGROUND,
        body: upCommingAppointments(),
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
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                ALL_APPOINTMENTS,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: WHITE, fontSize: 22),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget upCommingAppointments() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            FutureBuilder(
              future: loadAppointments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: MediaQuery.of(context).size.height - 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done &&
                    isAppointmentExist) {
                  return ListView.builder(
                    itemCount: nextUrl == "null"
                        ? list.length
                        : list.length + 1 + (list.length / 4).floor(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (list.length == index) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: LinearProgressIndicator(),
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            appointmentListWidget(index, list),
                            Container()
                          ],
                        );
                      }
                    },
                  );
                } else {
                  return Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset(
                          "assets/homeScreenImages/no_appo_img.png"),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget appointmentListWidget(int index, List<AppointmentData> data) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserAppointmentDetails(data[index].id.toString())));
      },
      child: Container(
        height: 90,
        margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: WHITE,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: data[index].image,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).primaryColorLight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      "assets/homeScreenImages/user_unactive.png",
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
                errorWidget: (context, url, err) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        "assets/homeScreenImages/user_unactive.png",
                        height: 20,
                        width: 20,
                      ),
                    )),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[index].name,
                          style: GoogleFonts.poppins(
                              color: BLACK,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          data[index].departmentName,
                          style: GoogleFonts.poppins(
                              color: BLACK,
                              fontSize: 11,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 10,),
                  Container(
                    child: Text(
                      data[index].address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: LIGHT_GREY_TEXT,
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/homeScreenImages/calender.png",
                  height: 17,
                  width: 17,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  data[index].date.toString().substring(8) +
                      "-" +
                      data[index].date.toString().substring(5, 7) +
                      "-" +
                      data[index].date.toString().substring(0, 4),
                  style: GoogleFonts.poppins(
                      color: LIGHT_GREY_TEXT,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  data[index].slot,
                  style: GoogleFonts.poppins(
                      color: BLACK, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
