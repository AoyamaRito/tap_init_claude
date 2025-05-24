import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize progress provider
  final progressProvider = ProgressProvider();
  await progressProvider.initialize();
  
  runApp(MyApp(progressProvider: progressProvider));
}

class MyApp extends StatelessWidget {
  final ProgressProvider progressProvider;
  
  const MyApp({super.key, required this.progressProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progressProvider),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Tap Initials',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        routes: {
          '/': (context) => const HomeScreen(),
          '/game': (context) => const GameScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}