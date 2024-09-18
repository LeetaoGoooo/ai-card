import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:word_to_card/api/claude.dart';
import 'package:word_to_card/pages/social_card_page.dart';
import 'package:word_to_card/pages/svg_page.dart';
import 'package:word_to_card/templates/index.dart';

class IntroCard extends StatefulWidget {
  final Template template;

  const IntroCard({super.key, required this.template});

  @override
  State<StatefulWidget> createState() => IntroCardState();
}

class IntroCardState extends State<IntroCard> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    return Card(
      child: ListTile(
        title: Text(template.templateProperty.name),
        subtitle: Text(
          template.templateProperty.description,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          if (template is SocialCard) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SocialCardPage(
                        template: template,
                      )),
            );
          } else {
            final dialog =
                configDialog(template.templateProperty.name, context);
            final confirm = await showDialog<bool>(
                context: context, builder: (ctx) => dialog);
            if (confirm ?? false) {
              if (!context.mounted) return;
              showLoadingDialog(context);
              final userInput = controller.text.trim();
              try {
                final svgString = await widget.template.generateSvgString(userInput);
                if (!context.mounted) return;
                Navigator.of(context).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext ctx) => SvgPage(
                            svgString: svgString,
                          )),
                );
              }  catch (e) {

                Fluttertoast.showToast(
                    msg: 'An error occurred: $e',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }
              finally {
                if (context.mounted) {
                  Navigator.of(context).pop();
                };
              }
            }
          }
        },
      ),
    );
  }

  Widget configDialog(String title, BuildContext ctx) {
    return AlertDialog(
      title: Text(title),
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: controller,
          validator: (value) => value!.isEmpty ? '请输入关键词' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('确定'),
        ),
      ],
    );
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
