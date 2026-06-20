import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import 'message_model.dart';

// 1. Proveedor para inyectar nuestro AiService
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

// 2. Proveedor para el estado de la lista de mensajes
final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final aiService = ref.watch(aiServiceProvider);
  return ChatNotifier(aiService);
});

// 3. El Notifier que maneja la lógica
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AiService _aiService;
  bool isLoading = false;

  ChatNotifier(this._aiService) : super([]);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // A. Agregamos el mensaje del usuario a la lista
    state = [...state, ChatMessage(text: text, role: MessageRole.user)];
    isLoading = true; // Iniciamos la carga

    try {
      // B. Llamamos a Gemini (¡Acá sucede la magia!)
      final response = await _aiService.sendMessage(text);

      // C. Agregamos la respuesta de la IA
      if (response != null) {
        state = [...state, ChatMessage(text: response, role: MessageRole.ai)];
      } else {
        state = [
          ...state,
          ChatMessage(
            text: "Hubo un error, respuesta vacía.",
            role: MessageRole.ai,
          ),
        ];
      }
    } catch (e) {
      // Si Gemini falla (por ej: error de API Key)
      state = [
        ...state,
        ChatMessage(
          text: "Error de conexión con la IA: $e",
          role: MessageRole.ai,
        ),
      ];
    } finally {
      isLoading = false; // Terminamos la carga
    }
  }
}
