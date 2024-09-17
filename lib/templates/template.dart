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
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }
}