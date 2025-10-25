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

    // 🔹 Roles con acceso total
    final rolesAccesoTotal = [
      'admin',
      'recursos',
      'bodega',
      'produccion',
      'ventas'
    ];

    final bool tieneAccesoTotal =
        rolesAccesoTotal.contains(usuario?.rol.toLowerCase() ?? '');
    final bool esEmpleado = usuario?.rol.toLowerCase() == 'empleado';

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



            // 🎂 Registrar cumpleaños
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



            // 📅 Ver calendario de cumpleaños
            _buildMenuButton(
              context,
              icon: Icons.calendar_month_rounded,
              color: Colors.teal,
              title: '📅 Ver Calendario de Cumpleaños',
              subtitle:
                  'Consulta las fechas importantes de tus compañeros de planta.',
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
            Divider(color: Colors.grey.shade300, thickness: 1.2),
            const SizedBox(height: 10),
            _buildLeyenda(),
          ],
        ),
      ),
    );
  }

  // 🔹 Botón de menú estilizado
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

  //  Colores por Planta
  Widget _buildLeyenda() {
    final leyenda = [
      {'color': Colors.blue.shade600, 'texto': 'Planta Administrativa'},
      {'color': Colors.purple.shade500, 'texto': 'Planta de Recursos Humanos'},
      {'color': Colors.orange.shade600, 'texto': 'Planta de Bodega'},
      {'color': Colors.green.shade600, 'texto': 'Planta de Producción'},
      {'color': Colors.red.shade500, 'texto': 'Planta de Ventas'},
      {'color': Colors.pinkAccent, 'texto': 'Cumpleaños 🎂'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📘 Leyenda de Colores',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: leyenda
              .map(
                (e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: e['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(e['texto'] as String),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
