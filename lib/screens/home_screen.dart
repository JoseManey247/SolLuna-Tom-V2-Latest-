import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenida de nuevo!',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '¿Qué deseas gestionar hoy en SolLuna?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 40),
          // Quick Access Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
                children: [
                  _buildQuickAccessCard(
                    context,
                    index: 1,
                    icon: Icons.book_outlined,
                    label: 'Catálogo de Productos',
                    color: const Color(0xFF8B5E3C),
                  ),
                  _buildQuickAccessCard(
                    context,
                    index: 2,
                    icon: Icons.local_pharmacy_outlined,
                    label: 'Recetario Maestro',
                    color: const Color(0xFFC4A484),
                  ),
                  _buildQuickAccessCard(
                    context,
                    index: 3,
                    icon: Icons.storefront_outlined,
                    label: 'Punto de Venta',
                    color: const Color(0xFF8B5E3C),
                  ),
                  _buildQuickAccessCard(
                    context,
                    index: 4,
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventario Productos',
                    color: const Color(0xFFC4A484),
                  ),
                  _buildQuickAccessCard(
                    context,
                    index: 5,
                    icon: Icons.soup_kitchen_outlined,
                    label: 'Inventario Ingredientes',
                    color: const Color(0xFF8B5E3C),
                  ),
                  _buildQuickAccessCard(
                    context,
                    index: 6,
                    icon: Icons.settings_outlined,
                    label: 'Configuración',
                    color: const Color(0xFFD2B48C),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          // Mini Dashboard / Status Section
          Text(
            'Estado Actual',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusMiniCard(
                  'Productos con bajo stock',
                  '5',
                  Icons.warning_amber_rounded,
                  Colors.orange[800]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusMiniCard(
                  'Ventas de hoy',
                  '\$42.500',
                  Icons.trending_up_rounded,
                  Colors.green[800]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(BuildContext context, {required int index, required IconData icon, required String label, required Color color}) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => onNavigate(index),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.05), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
