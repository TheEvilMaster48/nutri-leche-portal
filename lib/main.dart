import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutri_leche/screens/cumpleanios_screen.dart';
import 'package:provider/provider.dart';

// Seervice
import 'core/locale_provider.dart';
import 'services/auth_service.dart';
import 'services/evento_service.dart';
import 'services/notificacion_service.dart';
import 'services/usuario_service.dart';
import 'services/global_notifier.dart';
import 'services/language_service.dart';

//  Screens
import 'screens/login.dart' as login_screen;
import 'screens/registro.dart';
import 'screens/menu.dart';
import 'screens/eventos.dart';
import 'screens/notificaciones.dart';
import 'screens/chat.dart';
import 'screens/recursos.dart';
import 'screens/crear_evento.dart';
import 'screens/perfil.dart';
import 'screens/reconocimientos_screen.dart';
import 'screens/beneficios_screen.dart';
import 'screens/celebracion_screen.dart';
import 'screens/calendario_evento_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/buzon_sugerencias_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EventoService()),
        ChangeNotifierProvider(create: (_) => NotificacionService()),
        ChangeNotifierProvider(create: (_) => UsuarioService()),
        ChangeNotifierProvider(create: (_) => GlobalNotifier()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Nutri Leche Portal (Local)',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const login_screen.LoginScreen(),
            '/registro': (context) => const RegistroScreen(),
            '/menu': (context) => const MenuScreen(),
            '/eventos': (context) => const EventosScreen(),
            '/notificaciones': (context) => const NotificacionesScreen(),
            '/chat': (context) => const ChatScreen(),
            '/recursos': (context) => const RecursosScreen(),
            '/crear_evento': (context) => const CrearEventoScreen(),
            '/perfil': (context) => const PerfilScreen(),
            '/reconocimientos': (context) => const ReconocimientosScreen(),
            '/beneficios': (context) => const BeneficiosScreen(),
            '/celebraciones': (context) => const CelebracionesScreen(),
            '/calendario': (context) => const CalendarioEventosScreen(),
            '/cumpleanios': (context) => const CumpleaniosScreen(),
            '/agenda': (context) => const AgendaScreen(),
            '/buzon': (context) => const BuzonSugerenciasScreen(),
          },
        );
      },
    );
  }
}
