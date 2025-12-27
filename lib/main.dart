import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zdwmqnxwaimbbbaqhtxp.supabase.co',
    anonKey: 'sb_publishable_1dIpu69-P5vQjPB2a8oSYw_XFmYWXy7',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoke Free Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF98FF98),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF98FF98),
          primary: const Color(0xFF98FF98),
          secondary: const Color(0xFF7FDF7F),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        // Create profile only if it doesn't exist
        _createUserProfileIfNotExists(session.user.id);
      }
    });
  }

  Future<void> _createUserProfileIfNotExists(String userId) async {
    try {
      final existingProfile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .limit(1);

      // Only create default profile if one doesn't exist
      if (existingProfile.isEmpty) {
        await Supabase.instance.client.from('profiles').upsert({
          'user_id': userId,
          'nickname': 'User${userId.substring(0, 6)}',
        }, onConflict: 'user_id');
      }
      // If profile already exists, do NOTHING - don't overwrite!
    } catch (e) {
      print('Profile creation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            return const HomeScreen();
          }
        }
        return const AuthScreen();
      },
    );
  }
}
