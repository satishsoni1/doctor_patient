//import 'package:facebook_audience_network/ad/ad_native.dart';
//import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

import 'main.dart';

class CustomAds {
  final String ADMOB_ID = "ca-app-pub-7803172892594923/5172476997";
  final String FACEBOOK_AD_ID = "727786934549239_727793487881917";

  // final nativeAdController = NativeAdmobController();

  Widget nativeAds({@required int id}) {
    return
        //id==0
        //    ?
        Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: NativeAds(),
    );
    //   FacebookNativeAd(
    //     placementId: FACEBOOK_AD_ID,
    //     adType: NativeAdType.NATIVE_BANNER_AD,
    //     bannerAdSize: NativeBannerAdSize.HEIGHT_50,
    //     width: double.infinity,
    //     backgroundColor: Colors.blue,
    //     titleColor: Colors.white,
    //     descriptionColor: Colors.white,
    //     buttonColor: Colors.deepPurple,
    //     buttonTitleColor: Colors.white,
    //     buttonBorderColor: Colors.white,
    //     listener: (result, value) {
    //       print("Native Ad: $result --> $value");
    //     },
    //   );
  }
}

class NativeAds extends StatefulWidget {
  const NativeAds({Key key}) : super(key: key);

  @override
  _NativeAdsState createState() => _NativeAdsState();
}

class _NativeAdsState extends State<NativeAds>
    with AutomaticKeepAliveClientMixin {
  Widget child;

  final controller = NativeAdController();

  @override
  void initState() {
    super.initState();
    controller.load();
    controller.onEvent.listen((event) {
      if (event.keys.first == NativeAdEvent.loaded) {
        printAdDetails(controller);
      }
      setState(() {});
    });
  }

  void printAdDetails(NativeAdController controller) async {
    /// Just for showcasing the ability to access
    /// NativeAd's details via its controller.
    print("------- NATIVE AD DETAILS: -------");
    print(controller.headline);
    print(controller.body);
    print(controller.price);
    print(controller.store);
    print(controller.callToAction);
    print(controller.advertiser);
    print(controller.iconUri);
    print(controller.imagesUri);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (child != null) return child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.isLoaded)
          NativeAd(
            unitId: ADMOB_ID,
            controller: controller,
            height: 60,
            builder: (context, child) {
              return Material(
                elevation: 8,
                child: child,
              );
            },
            buildLayout: adBannerLayoutBuilder,
            loading: SizedBox(),
            error: SizedBox(),
            icon: AdImageView(padding: EdgeInsets.only(left: 6)),
            headline: AdTextView(style: TextStyle(color: Colors.black)),
            advertiser: AdTextView(style: TextStyle(color: Colors.black)),
            body:
                AdTextView(style: TextStyle(color: Colors.black), maxLines: 1),
            media: AdMediaView(height: 70, width: 120),
            button: AdButtonView(
              margin: EdgeInsets.only(left: 6, right: 6),
              textStyle: TextStyle(color: Colors.green, fontSize: 14),
              elevation: 18,
              elevationColor: Colors.amber,
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

AdLayoutBuilder get fullBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribuition, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        decoration: AdDecoration(
            gradient: AdLinearGradient(
          colors: [Colors.indigo[300], Colors.indigo[700]],
          orientation: AdGradientOrientation.tl_br,
        )),
        children: [
          media,
          AdLinearLayout(
            children: [
              icon,
              AdLinearLayout(children: [
                headline,
                AdLinearLayout(
                  children: [attribuition, advertiser, ratingBar],
                  orientation: HORIZONTAL,
                  width: MATCH_PARENT,
                ),
              ], margin: EdgeInsets.only(left: 4)),
            ],
            gravity: LayoutGravity.center_horizontal,
            width: WRAP_CONTENT,
            orientation: HORIZONTAL,
            margin: EdgeInsets.only(top: 6),
          ),
          AdLinearLayout(
            children: [button],
            orientation: HORIZONTAL,
          ),
        ],
      );
    };

AdLayoutBuilder get secondBuilder => (ratingBar, media, icon, headline,
        advertiser, body, price, store, attribution, button) {
      return AdLinearLayout(
        padding: EdgeInsets.all(10),
        // The first linear layout width needs to be extended to the
        // parents height, otherwise the children won't fit good
        width: MATCH_PARENT,
        orientation: HORIZONTAL,
        decoration: AdDecoration(
          gradient: AdRadialGradient(
            colors: [Colors.blue[300], Colors.blue[900]],
            center: Alignment(0.5, 0.5),
            radius: 1000,
          ),
        ),
        children: [
          icon,
          AdLinearLayout(
            children: [
              headline,
              AdLinearLayout(
                children: [attribution, advertiser, ratingBar],
                orientation: HORIZONTAL,
                width: WRAP_CONTENT,
                height: 20,
              ),
              button,
            ],
            margin: EdgeInsets.symmetric(horizontal: 4),
          ),
        ],
      );
    };
