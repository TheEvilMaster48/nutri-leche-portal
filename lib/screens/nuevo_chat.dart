import 'package:flutter/material.dart';

class NuevoChatScreen extends StatelessWidget {
  const NuevoChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4ADE80),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, cargo o teléfono',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildContactTile(
                  'María González',
                  'Supervisora de Producción',
                  '+593 99 111 2222',
                  'M',
                  const Color(0xFF4ADE80),
                ),
                _buildContactTile(
                  'Carlos Mendoza',
                  'Jefe de Calidad',
                  '+593 99 333 4444',
                  'C',
                  const Color(0xFF4ADE80),
                ),
                _buildContactTile(
                  'Ana Rodríguez',
                  'Recursos Humanos',
                  '+593 99 555 6666',
                  'A',
                  const Color(0xFF4ADE80),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(String nombre, String cargo, String telefono, String inicial, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(inicial, style: const TextStyle(color: Colors.white)),
      ),
      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cargo),
          Text(telefono, style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF4ADE80)),
      onTap: () {},
    );
  }
}
