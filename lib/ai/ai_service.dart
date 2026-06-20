import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_constants.dart';

class AiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(AiConfig.plumbingAiSystemPrompt), 
    );

    _chatSession = _model.startChat();
  }

  Future<String?> sendMessage(String userText) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(userText));
      return response.text;
    } catch (e) {
      debugPrint('Error al comunicarse con la IA: $e');
      return 'Hubo un error al procesar tu solicitud. Por favor, intentá de nuevo.';
    }
  }
}