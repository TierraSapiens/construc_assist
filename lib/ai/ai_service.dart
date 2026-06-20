import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_constants.dart'; // Importamos tu archivo de configuración

class AiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiService() {
    // Inicializamos el modelo de la IA
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // El modelo más rápido para chats
      apiKey: _apiKey,
      // ¡Acá inyectamos el molde que creamos!
      systemInstruction: Content.system(AiConfig.plumbingAiSystemPrompt), 
    );

    // Iniciamos la sesión de chat vacía
    _chatSession = _model.startChat();
  }

  // Esta es la función que vas a llamar cada vez que el usuario escriba algo
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