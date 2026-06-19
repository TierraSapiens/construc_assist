import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_config.dart'; // Importamos tu archivo de configuración

class AiService {
  // Acá va tu clave de API (idealmente sacada de variables de entorno, no hardcodeada)
  final String _apiKey = 'TU_API_KEY_AQUI'; 
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
      print('Error al comunicarse con la IA: $e');
      return 'Hubo un error al procesar tu solicitud. Por favor, intentá de nuevo.';
    }
  }
}