import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import 'message_model.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final aiService = ref.watch(aiServiceProvider);
  return ChatNotifier(aiService);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AiService _aiService;
  bool isLoading = false;

  ChatNotifier(this._aiService) : super([]);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = [...state, ChatMessage(text: text, role: MessageRole.user)];
    isLoading = true;

    try {
      final response = await _aiService.sendMessage(text);
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
      state = [
        ...state,
        ChatMessage(
          text: "Error de conexión con la IA: $e",
          role: MessageRole.ai,
        ),
      ];
    } finally {
      isLoading = false;
    }
  }
}
