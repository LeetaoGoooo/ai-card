import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:word_to_card/pages/svg_page.dart';
import 'package:word_to_card/templates/index.dart';

class SocialCardPage extends StatefulWidget {
  final Template template;

  const SocialCardPage({super.key, required this.template});

  @override
  _SocialCardPageState createState() => _SocialCardPageState();
}

class _SocialCardPageState extends State<SocialCardPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _recentFocusController = TextEditingController();
  final List<TextEditingController> _highlightControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _skillNameControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _skillDescControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _hobbyControllers =
      List.generate(4, (_) => TextEditingController());
  final TextEditingController _attitudeController = TextEditingController();
  String? base64Image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人社交卡片生成器')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    child: Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                              radius: 30,
                              child: base64Image == null
                                  ? const SizedBox()
                                  : ClipOval(
                                      child: Image.memory(
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          const Base64Decoder()
                                              .convert(base64Image!)))),
                          const Text("上传头像")
                        ],
                      ),
                    ),
                    onTap: () async {
                      try {
                        final XFile? pickedFile = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          final base64PickedFileImage =
                              base64Encode(await pickedFile.readAsBytes());
                          setState(() {
                            base64Image = base64PickedFileImage;
                          });
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg: "上传照片失败",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    }),
                Text('姓名',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? '请输入姓名' : null,
                ),
                const SizedBox(height: 16),
                Text('地点',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? '请输入地点' : null,
                ),
                const SizedBox(height: 16),
                Text('身份标签',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _tagController,
                  decoration:
                      const InputDecoration(label: Text("多个标签可以以 ',' 逗号进行分割")),
                ),
                const SizedBox(height: 16),
                Text('近期关键投入',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _recentFocusController,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? '请输入近期关键投入' : null,
                ),
                const SizedBox(height: 16),
                Text('履历亮点',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                for (int i = 0; i < 3; i++)
                  TextFormField(
                    controller: _highlightControllers[i],
                    decoration: InputDecoration(labelText: '亮点 ${i + 1}'),
                  ),
                const SizedBox(height: 16),
                Text('擅长领域',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                for (int i = 0; i < 4; i++) ...[
                  TextFormField(
                    controller: _skillNameControllers[i],
                    decoration: InputDecoration(labelText: '领域 ${i + 1} 名称'),
                  ),
                ],
                const SizedBox(height: 16),
                Text('兴趣爱好',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                for (int i = 0; i < 4; i++)
                  TextFormField(
                    controller: _hobbyControllers[i],
                    decoration:
                        InputDecoration(labelText: '爱好 ${i + 1} (包含emoji)'),
                  ),
                const SizedBox(height: 16),
                Text('个人态度',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _attitudeController,
                  decoration: const InputDecoration(),
                  validator: (value) => value!.isEmpty ? '请输入个人态度' : null,
                  maxLength: 25,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!context.mounted) return;
                        showLoadingDialog(context);
                        final userInput = getFormData();
                        try {
                          final svgString = await widget.template
                              .generateSvgString(userInput);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext ctx) =>
                                      SvgPage(svgString: svgString)));
                        } finally {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    },
                    child: const Text('提交'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _tagController.dispose();

    _recentFocusController.dispose();
    for (var controller in _highlightControllers) {
      controller.dispose();
    }
    for (var controller in _skillNameControllers) {
      controller.dispose();
    }
    for (var controller in _skillDescControllers) {
      controller.dispose();
    }
    for (var controller in _hobbyControllers) {
      controller.dispose();
    }
    _attitudeController.dispose();
    super.dispose();
  }

  String getFormData() {
    final Map<String, String> data = {
      '姓名': _nameController.text,
      '地点': _locationController.text,
      '身份标签': _tagController.text,
      '近期关键投入': _recentFocusController.text,
      '履历亮点1': _highlightControllers[0].text,
      '履历亮点2': _highlightControllers[1].text,
      '履历亮点3': _highlightControllers[2].text,
      '擅长领域1': _skillNameControllers[0].text,
      '擅长领域2': _skillNameControllers[1].text,
      '擅长领域3': _skillNameControllers[2].text,
      '擅长领域4': _skillNameControllers[3].text,
      '兴趣爱好1': _hobbyControllers[0].text,
      '兴趣爱好2': _hobbyControllers[1].text,
      '兴趣爱好3': _hobbyControllers[2].text,
      '兴趣爱好4': _hobbyControllers[3].text,
      '个人态度': _attitudeController.text,
    };

    return data.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => '${entry.key}:${entry.value};')
        .join(' ');
  }

  void showLoadingDialog(BuildContext ctx) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
        );
      },
    );
  }
}
