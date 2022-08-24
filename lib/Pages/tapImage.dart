import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class TapImage extends StatelessWidget {
  final downloadUrl;
  const TapImage({ Key key , @required this.downloadUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CachedNetworkImage
          (
            placeholder: (context, url) => Container(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                      child: LoadingIndicator(
                                     indicatorType: Indicator.circleStrokeSpin,
                                    
                                    colors: [Colors.green],
                                  ))),
                              imageUrl: downloadUrl
            // child: Image.network(downloadUrl)
          ))
        ),
      ),
    );
  }
}