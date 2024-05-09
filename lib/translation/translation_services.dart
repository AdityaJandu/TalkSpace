import 'package:translator/translator.dart';

class TranslationService {
  static final translator = GoogleTranslator();

  // Function to translate text from English to Hindi
  static Future<String> translateToHindi(String text) async {
    try {
      var translation = await translator.translate(text, from: 'en', to: 'hi');
      return translation.text;
    } catch (error) {
      print('Translation error: $error');
      return text; // Fallback to original text if translation fails
    }
  }
}
