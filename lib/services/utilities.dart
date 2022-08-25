import 'dart:developer';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class Utilities extends ChangeNotifier {
  PendingDynamicLinkData referralLink;
  String referCode;
  Utilities({this.referralLink}) {
    if (this.referralLink != null) {
      getCodeFromLink();
    }
  }

  subsribeSream() {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (dynamicLinkData != null) {
        log("link present " + dynamicLinkData.link.toString());
        this.referralLink = dynamicLinkData;
        getCodeFromLink();
      }
    }).onError((error) {
      log(error.toString());
    });
  }

  getCodeFromLink() {
    if (this.referralLink != null) {
      final Uri deepLink = referralLink.link;
      final queryParams = deepLink.queryParameters;
      if (queryParams.length > 0) {
        this.referCode = queryParams['code'];
        notifyListeners();
      }
    }
  }
}
