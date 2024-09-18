import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

class SvgPage extends StatelessWidget {
  final String svgString;

  const SvgPage({super.key, required this.svgString});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
        appBar: AppBar(
          title: const Text("卡片"),
          leading: BackButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(
              replaceSvgDimensions(svgString, width, height),
            ),
            const SizedBox(height: 20,),
            SizedBox(
                height: 60,
                width: width - 20,
                child: ElevatedButton(
                  onPressed: () async {
                    var granted = await _requestPermission();
                    if (granted) {
                      final imageBytes = await svgStringToPngBytes(replaceSvgDimensions(svgString, width, height));
                      String picturesPath =
                          "${DateTime.now().millisecondsSinceEpoch}.jpg";
                      final res = await SaverGallery.saveImage(
                        imageBytes,
                        name: picturesPath,
                        androidExistNotSave: false,
                      );
                      var snackBar = '保存到相册成功!';
                      if (!res.isSuccess) {
                        snackBar = '保存到相册失败!';
                      }
                      Fluttertoast.showToast(
                          msg: snackBar,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                  child: const Text("保存"),
                ),
              ),
          ],
        )));
  }

  Future<Uint8List> svgStringToPngBytes(
    // The SVG string
    String svgStringContent,
  ) async {
    final SvgStringLoader svgStringLoader = SvgStringLoader(svgStringContent);
    final PictureInfo pictureInfo = await vg.loadPicture(svgStringLoader, null);
    final ui.Picture picture = pictureInfo.picture;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(
        recorder,
        Rect.fromPoints(Offset.zero,
            Offset(pictureInfo.size.width, pictureInfo.size.height)));
    canvas.drawPicture(picture);
    final ui.Image imgByteData = await recorder
        .endRecording()
        .toImage(pictureInfo.size.width.ceil(), pictureInfo.size.height.ceil());
    final ByteData? bytesData =
        await imgByteData.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = bytesData?.buffer.asUint8List() ?? Uint8List(0);
    pictureInfo.picture.dispose();
    return imageData;
  }

  _requestPermission() async {
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      bool statuses =
          sdkInt < 29 ? await Permission.storage.request().isGranted : true;
      return statuses;
    } else {
      return true;
    }
  }

  String replaceSvgDimensions(String svgString, double width, double height) {
    // Replace width attribute
    var widthRegex = RegExp(r'width="100%"');
    svgString = svgString.replaceAll(widthRegex, 'width="$width"');

    // Replace height attribute
    var heightRegex = RegExp(r'height=("100%")');
    svgString = svgString.replaceAll(heightRegex, 'height="$height"');

    widthRegex = RegExp(r"width='100%'");
    svgString = svgString.replaceAll(widthRegex, 'width="$width"');

    // Replace height attribute
    heightRegex = RegExp(r"height=('100%')");
    svgString = svgString.replaceAll(heightRegex, 'height="$height"');

    // If width or height attributes don't exist, add them
    if (!svgString.contains('width=')) {
      svgString = svgString.replaceFirst('<svg', '<svg width="$width"');
    }
    if (!svgString.contains('height=')) {
      svgString = svgString.replaceFirst('<svg', '<svg height="$height"');
    }

    return svgString;
  }
}
