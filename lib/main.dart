import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:word_to_card/pages/widgets/intro_card.dart';
import 'package:word_to_card/share_prefs.dart';
import 'package:word_to_card/templates/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ai Card',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ai Card'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SharedPrefs sharedPrefs = SharedPrefs();
  late TextEditingController _apiKey;
  late final TextEditingController _endPoint;


  final List<Template> templates = [
    ChineseInterpretation(),
    EnglishFlashCard(),
    SocialCard(),
    Thinker(),
    FaithfulExpressiveElegantTranslation(),
    KnowledgeCard(),
    InternetJargonExpert(),
    Philosopher(),
    AnswerBook()
  ];

  @override
  void initState() {
    _apiKey = TextEditingController(text: sharedPrefs.apiKey ?? "");
    _endPoint = TextEditingController(text:sharedPrefs.baseUrl ?? "");
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: GridView.count(
                shrinkWrap: true,
                childAspectRatio: (2 / 1),
                semanticChildCount: 2,
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: templates
                    .map((template) => IntroCard(template: template))
                    .toList(),
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) => SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ApiKey', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: _apiKey,
                        validator: (value) => value!.isEmpty ? '请输入正确的 ApiKey' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Base Url', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextFormField(
                        controller: _endPoint,
                        validator: (value) => value!.isEmpty ? '请输入正确的 Base Url' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("取消")),
                          ElevatedButton(onPressed: () {
                            sharedPrefs.apiKey = _apiKey.text.trim();
                            sharedPrefs.baseUrl = _endPoint.text.trim();
                            Fluttertoast.showToast(
                                msg: '保存成功!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                            Navigator.of(context).pop();
                          }, child: const Text("保存"))
                        ],
                      )
                    ],),
                ),
              ),
            ),
          );
        },
        tooltip: 'Config',
        child: const Icon(Icons.settings),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
