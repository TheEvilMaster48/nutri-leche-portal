import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final usuario = auth.currentUser;
    final rol = usuario?.rol ?? 'empleado';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Menús
    final List<Map<String, dynamic>> menus = [
      {
        'titulo': 'Eventos',
        'subtitulo': rol == 'admin'
            ? 'Gestionar eventos'
            : 'Ver calendario y actividades',
        'icono': Icons.event_available_rounded,
        'ruta': '/eventos',
        'colores': [
          const Color.fromARGB(255, 0, 72, 255),
          const Color(0xFF64B5F6)
        ],
      },
      {
        'titulo': 'Notificaciones',
        'subtitulo':
            rol == 'admin' ? 'Avisos del sistema' : 'Ver avisos importantes',
        'icono': Icons.notifications_active_rounded,
        'ruta': '/notificaciones',
        'colores': [
          const Color.fromARGB(255, 250, 0, 0),
          const Color(0xFF00ACC1)
        ],
      },
      {
        'titulo': 'Chat',
        'subtitulo': 'Comunicación interna',
        'icono': Icons.chat_rounded,
        'ruta': '/chat',
        'colores': [
          const Color.fromARGB(255, 0, 150, 7),
          const Color(0xFF81C784)
        ],
      },
      {
        'titulo': 'Recursos',
        'subtitulo': 'Editar, descargar y administrar documentos',
        'icono': Icons.folder_copy_rounded,
        'ruta': '/recursos',
        'colores': [
          const Color.fromARGB(255, 157, 0, 255),
          const Color(0xFF9575CD)
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 121, 145),
      body: SafeArea(
        child: Column(
          children: [
            // Botón cerrar sesión
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

            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/icono/nutrileche.png'),
                  fit: BoxFit.contain,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Nombre y Rol
            Text(
              usuario?.nombreCompleto ?? 'Usuario',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Mostrar planta según el rol o área real
            Text(
              () {
                if (usuario == null) return 'Rol: Empleado';

                switch (usuario.username) {
                  case 'admin':
                    return 'Rol: Planta Administrativa';
                  case 'recursos':
                    return 'Rol: Planta Recursos Humanos';
                  case 'bodega':
                    return 'Rol: Planta Bodega';
                  case 'produccion':
                    return 'Rol: Planta Producción';
                  case 'ventas':
                    return 'Rol: Planta Ventas';
                  default:
                    return 'Rol: Empleado';
                }
              }(),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            // Línea sombreada
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

            // Contenedor botones
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
                    children: menus.map((menu) {
                      return _buildMenuButton(
                        context,
                        menu['titulo'],
                        menu['subtitulo'],
                        menu['icono'],
                        menu['colores'][0],
                        menu['colores'][1],
                        menu['ruta'],
                      );
                    }).toList(),
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

  // Botón del menú
  Widget _buildMenuButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color1,
    Color color2,
    String route,
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.4),
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
