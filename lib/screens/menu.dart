import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 1, 121, 145), //Color Fondo Principal
      body: SafeArea(
        child: Column(
          children: [
            // Botón de cerrar sesión
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
            ),

            // Logo personalizado
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/icono/nutrileche.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Título principal
            const Text(
              'Nutri Leche',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ecuador - Portal de Empleados',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 20),

            // Línea negra sombreada
            Container(
              height: 4,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Recuadro central con los botones
            Expanded(
              child: Center(
                child: Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.55,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 5, 213, 255),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 5, 213, 255)
                            .withOpacity(0.6),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 22,
                    mainAxisSpacing: 24,
                    childAspectRatio: 2.8,
                    shrinkWrap: true,
                    children: [
                      _buildMenuButton(
                        context,
                        'Eventos',
                        'Calendario y actividades',
                        Icons.event_available_rounded,
                        const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 4, 255),
                            Color(0xFF64B5F6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        '/eventos',
                      ),
                      _buildMenuButton(
                        context,
                        'Notificaciones',
                        'Mensajes y alertas del sistema',
                        Icons.notifications_rounded,
                        const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 1, 1),
                            Color(0xFF00ACC1)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        '/notificaciones',
                      ),
                      _buildMenuButton(
                        context,
                        'Chat',
                        'Comunicación interna',
                        Icons.chat_rounded,
                        const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 0, 152, 8),
                            Color(0xFF81C784)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        '/chat',
                      ),
                      _buildMenuButton(
                        context,
                        'Recursos',
                        'Documentos y políticas',
                        Icons.folder_copy_rounded,
                        const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 140, 73, 255),
                            Color(0xFF9575CD)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        '/recursos',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    LinearGradient gradient,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 14),
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
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
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
