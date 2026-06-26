import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_constants.dart';

class AiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  AiService() {
    _model = GenerativeModel(
      model: 'gemini-3.5-flash',
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
      return 'ERROR TÉCNICO: $e';
    }
  }

  // --- NUEVA FUNCIÓN PARA PRESUPUESTOS ---
  Future<String?> generarPresupuesto(String descripcionTrabajo) async {
    try {
      // A diferencia del chat, acá creamos un modelo de un solo uso
      // porque solo necesitamos una pregunta y una respuesta directa.
      final modeloEstructurado = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(AiConfig.budgetAiSystemPrompt),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json', // Le forzamos el formato
        ),
      );

      final response = await modeloEstructurado.generateContent([
        Content.text(descripcionTrabajo),
      ]);

      return response.text;
    } catch (e) {
      return 'ERROR TÉCNICO: $e';
    }
  }
}
