import 'package:flutter/material.dart';
import '../ai/ai_service.dart'; // Ajustá la ruta si es necesario
import '../ai/message_model.dart'; // Ajustá la ruta si es necesario

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AiService _aiService = AiService();
  final TextEditingController _textController = TextEditingController();
  
  // Lista donde guardamos la conversación
  final List<ChatMessage> _messages = []; 
  
  // Variable para mostrar un indicador de carga mientras la IA piensa
  bool _isLoading = false; 

  // Función principal para enviar y recibir
  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Agregamos el mensaje del usuario y limpiamos la caja de texto
    setState(() {
      _messages.add(ChatMessage(text: text, role: MessageRole.user));
      _isLoading = true; // Mostramos que la IA está escribiendo
    });
    
    _textController.clear();

    // 2. Esperamos la respuesta de nuestro AiService
    final response = await _aiService.sendMessage(text);

    // 3. Agregamos la respuesta de la IA a la pantalla
    setState(() {
      _isLoading = false;
      if (response != null) {
        _messages.add(ChatMessage(text: response, role: MessageRole.ai));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Plomería'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Zona de los mensajes (toma todo el espacio disponible)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == MessageRole.user;

                // Diseño de la burbuja de chat
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75, // Que no ocupe toda la pantalla
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Indicador de "Escribiendo..."
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Caja de texto inferior para escribir
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Describí tu problema de plomería...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Enviar al tocar "Enter" en el teclado
                    onSubmitted: (_) => _sendMessage(), 
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage, // Deshabilita el botón si está cargando
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}