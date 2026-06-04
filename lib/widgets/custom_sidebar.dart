import 'package:flutter/material.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFD2B48C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFD2B48C),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo_solluna.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SolLuna',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(context, 0, Icons.home, 'Home'),
          _buildMenuItem(context, 1, Icons.book, 'Catálogo'),
          _buildMenuItem(context, 2, Icons.local_pharmacy, 'Recetario'),
          _buildMenuItem(context, 3, Icons.store, 'Ventas'),
          _buildMenuItem(context, 4, Icons.inventory, 'Inventario de Productos'),
          _buildMenuItem(context, 5, Icons.soup_kitchen, 'Inventario de Ingredientes'),
          _buildMenuItem(context, 6, Icons.settings, 'Configuración'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF8B5E3C),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF8B5E3C),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 18,
        ),
      ),
      selected: isSelected,
      onTap: () => onItemTapped(index),
    );
  }
}
