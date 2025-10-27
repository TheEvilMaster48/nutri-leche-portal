import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../core/notification_banner.dart';
import '../models/notification_item.dart';
import '../models/usuario.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Mensaje de Bienvenida
    Future.delayed(const Duration(seconds: 1), () {
      final auth = context.read<AuthService>();
      auth.showNotification(
        "Bienvenido ${auth.currentUser?.nombreCompleto ?? ''}",
        "success",
      );
    });

    // Temporizador de Refresco
    _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final Usuario? usuario = auth.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;

    // Menús Principales
    final List<Map<String, dynamic>> menus = [
      {
        'titulo': 'Eventos',
        'subtitulo': 'Ver calendario y actividades',
        'icono': Icons.event_available_rounded,
        'ruta': '/eventos',
        'colores': [const Color(0xFF0048FF), const Color(0xFF64B5F6)],
      },
      {
        'titulo': 'Notificaciones',
        'subtitulo': 'Ver avisos importantes del sistema',
        'icono': Icons.notifications_active_rounded,
        'ruta': '/notificaciones',
        'colores': [const Color(0xFFFA0000), const Color(0xFF00ACC1)],
      },
      {
        'titulo': 'Chat',
        'subtitulo': 'Comunicación interna',
        'icono': Icons.chat_rounded,
        'ruta': '/chat',
        'colores': [const Color(0xFF009607), const Color(0xFF81C784)],
      },
      {
        'titulo': 'Recursos',
        'subtitulo': 'Documentos y archivos compartidos',
        'icono': Icons.folder_copy_rounded,
        'ruta': '/recursos',
        'colores': [const Color(0xFF9D00FF), const Color(0xFF9575CD)],
      },
      {
        'titulo': 'Reconocimientos',
        'subtitulo': 'Premios y logros de empleados',
        'icono': Icons.emoji_events_rounded,
        'ruta': '/reconocimientos',
        'colores': [const Color(0xFFFFC107), const Color(0xFFFFE082)],
      },
      {
        'titulo': 'Beneficios',
        'subtitulo': 'Programas y descuentos exclusivos',
        'icono': Icons.card_giftcard_rounded,
        'ruta': '/beneficios',
        'colores': [const Color(0xFF00BCD4), const Color(0xFF4DD0E1)],
      },
      {
        'titulo': 'Cumpleaños y aniversarios',
        'subtitulo': 'Celebra junto a tus compañeros',
        'icono': Icons.cake_rounded,
        'ruta': '/celebraciones', // ✅ Correcto
        'colores': [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
      },
      {
        'titulo': 'Calendario y eventos',
        'subtitulo': 'Agenda de actividades laborales',
        'icono': Icons.calendar_month_rounded,
        'ruta': '/calendario_eventos', // ✅ Corregido
        'colores': [const Color(0xFF3F51B5), const Color(0xFF7986CB)],
      },
      {
        'titulo': 'Agenda',
        'subtitulo': 'Organiza tus reuniones y tareas',
        'icono': Icons.schedule_rounded,
        'ruta': '/agenda',
        'colores': [const Color(0xFF4CAF50), const Color(0xFFA5D6A7)],
      },
      {
        'titulo': 'Buzón de sugerencias',
        'subtitulo': 'Envía tus ideas y comentarios',
        'icono': Icons.mail_rounded,
        'ruta': '/buzon',
        'colores': [const Color(0xFFFF5722), const Color(0xFFFFAB91)],
      },
      {
        'titulo': 'Perfil',
        'subtitulo': 'Ver información personal',
        'icono': Icons.person_rounded,
        'ruta': '/perfil',
        'colores': [const Color(0xFFFF9900), const Color(0xFFFFB74D)],
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // FONDO PRINCIPAL (COLOR Y LOGOTIPO)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF01579B), // Azul Oscuro
                    Color(0xFF0277BD), // Azul Medio
                    Color(0xFF03A9F4), // Celeste Brillante
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),



            // Logo centrado, detrás del contenido
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icono/nutrileche.png',
                width: 700,
                height: 700,
                fit: BoxFit.contain,
              ),
            ),

            // CONTENIDO PRINCIPAL
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    // Botón cerrar sesión
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await context.read<AuthService>().logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/');
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          tooltip: 'Cerrar Sesión',
                        ),
                      ],
                    ),



                    // Avatar de usuario
                    Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child:
                            Icon(Icons.person, size: 80, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),



                    // Nombre y Cargo
                    Text(
                      usuario?.nombreCompleto.toUpperCase() ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      _obtenerDescripcionUsuario(usuario),
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),



                    // Línea Decorativa
                    Container(
                      height: 4,
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Menú de opciones
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      alignment: WrapAlignment.center,
                      children: menus.map((menu) {
                        return _buildMenuButton(
                          context,
                          menu['titulo'],
                          menu['subtitulo'],
                          menu['icono'],
                          menu['colores'][0],
                          menu['colores'][1],
                          menu['ruta'],
                          screenWidth,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),



            // Notificaciones 
            NotificationBanner(
              load: () async {
                final auth = context.read<AuthService>();
                if (auth.currentNotification != null) {
                  final notif = auth.currentNotification!;
                  return [
                    NotificationItem(
                      id: 'local_banner',
                      tipo: notif['type'] ?? 'info',
                      titulo: notif['type'] == 'success'
                          ? 'Inicio de Sesión Exitoso'
                          : notif['type'] == 'error'
                              ? 'Error en Sesión'
                              : 'Aviso del Sistema',
                      detalle: notif['message'] ?? '',
                      refId: '',
                      fecha: DateTime.now(),
                    ),
                  ];
                }
                return [];
              },
              onClose: () => context.read<AuthService>().clearNotification(),
            ),
          ],
        ),
      ),
    );
  }


  // Descripción de Usuario 
  String _obtenerDescripcionUsuario(Usuario? usuario) {
    if (usuario == null) return 'Sin datos de usuario';
    if (usuario.cargo.isNotEmpty) return 'Cargo: ${usuario.cargo}';
    if (usuario.planta.isNotEmpty) return 'Planta: ${usuario.planta}';
    return 'Empleado Nutri Leche';
  }


  // Botón de los Menús
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color1,
    Color color2,
    String route,
    double screenWidth,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: screenWidth * 0.42,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 45, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
