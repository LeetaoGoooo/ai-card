import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

class SvgPage extends StatelessWidget {
  final String svgString;

  const SvgPage({super.key, required this.svgString});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("卡片"),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          SvgPicture.string(
            svgString,
          ),
          ElevatedButton(
              onPressed: () async {
                var granted = await _requestPermission();
                if (granted) {
                  final imageBytes = await svgStringToPngBytes(svgString);
                  String picturesPath =
                      "${DateTime.now().millisecondsSinceEpoch}.jpg";
                  final res = await SaverGallery.saveImage(imageBytes,
                      name: picturesPath, androidExistNotSave: false);
                  var snackBar = const SnackBar(content: Text('保存到相册成功!'));
                  if (!res.isSuccess) {
                    snackBar = const SnackBar(content: Text('保存到相册失败!'));
                  }
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              child: const Text("保存"))
        ],
      ),
    );
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
}
