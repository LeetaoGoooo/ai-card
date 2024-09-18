part of templates;

class TemplateProperty {
  final String name;
  final String author;
  final String description;
  final String? cover;
  final String prompt;
  TemplateProperty(this.prompt, {required this.name, required this.author, required this.description, this.cover});
}

abstract class Template {
  TemplateProperty get templateProperty;
  final Claude claude = Claude();

  Future<String> generateSvgString(String userInput) async {
    try {
      var res = await claude.post(templateProperty.prompt, userInput);
      if (res == null) {
        throw Exception("Empty response");
      }
      print("return:$res");
      final RegExp svgRegex = RegExp(r'<svg[\s\S]*?<\/svg>');
      final Match? svgMatch = svgRegex.firstMatch(res);
      final svgString = svgMatch?.group(0);
      if (svgString == null) {
        throw Exception("There is no svg returned in the response, please try again");
      }
      return svgString;
    } catch (e) {
      throw Exception(e);
    }
  }
}