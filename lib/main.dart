import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:construc_assist/core/settings/theme_provider.dart';
import 'package:construc_assist/features/home/ui/screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const ConstrucAssistApp(),
    ),
  );
}

class ConstrucAssistApp extends ConsumerWidget {
  const ConstrucAssistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final prefs = ref.watch(sharedPrefsProvider);
    final hasSelectedMode = prefs.containsKey('isObraMode');

    return MaterialApp(
      title: 'Construc Assist',
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: hasSelectedMode ? const MainMenuScreen() : const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '¿Cómo vas a trabajar hoy?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Boton MODO OBRA
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(isObraModeProvider.notifier).setMode(true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainMenuScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '👷 MODO OBRA\n(Alto Contraste)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Boton MODO OFICINA
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(isObraModeProvider.notifier).setMode(false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainMenuScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    '👔 MODO OFICINA\n(Elegante)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
