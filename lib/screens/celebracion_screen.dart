import 'package:flutter/material.dart';
import 'package:nutri_leche/screens/calendario_evento_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'cumpleanios_screen.dart';

class CelebracionesScreen extends StatelessWidget {
  const CelebracionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final usuario = auth.currentUser;

    // Roles con acceso total
    final rolesAccesoTotal = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];

    final bool tieneAccesoTotal =
        rolesAccesoTotal.contains(usuario?.rol.toLowerCase() ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text(
          '🎉 Celebraciones y Eventos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: Colors.teal,
              size: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido al módulo de Celebraciones y Eventos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),

            // Registrar cumpleaños
            if (tieneAccesoTotal)
              _buildMenuButton(
                context,
                icon: Icons.cake,
                color: Colors.pinkAccent,
                title: '🎂 Registrar Cumpleaños',
                subtitle: 'Agrega empleados para celebrar su día especial.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CumpleaniosScreen(),
                    ),
                  );
                },
              ),

            // Calendario de Cumpleaños y Eventos
            _buildMenuButton(
              context,
              icon: Icons.event_note,
              color: Colors.blue.shade600,
              title: '📅 Ver Calendario de Eventos',
              subtitle:
                  'Consulta los cumpleaños y actividades programadas en tu planta.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalendarioEventosScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1.2),
            const SizedBox(height: 15),
            _buildMiniLeyenda(),
          ],
        ),
      ),
    );
  }

  //  Botón de Menú 
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
        ),
      ),
    );
  }

  // LEYENDA ICONOS
  Widget _buildMiniLeyenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.event_note, color: Colors.blue, size: 20),
        const SizedBox(width: 6),
        const Text('Eventos',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(width: 20),
        const Icon(Icons.cake, color: Colors.pinkAccent, size: 20),
        const SizedBox(width: 6),
        const Text('Cumpleaños',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}
