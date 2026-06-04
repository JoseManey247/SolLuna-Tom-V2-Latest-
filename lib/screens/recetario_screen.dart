import 'package:flutter/material.dart';

class RecetarioScreen extends StatelessWidget {
  const RecetarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Recetario',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLargeActionButton(Icons.delete_outline, 'Eliminar receta', Colors.red[900]!),
              const SizedBox(width: 24),
              _buildLargeActionButton(Icons.edit_outlined, 'Modificar receta', Colors.orange[800]!),
              const SizedBox(width: 24),
              _buildLargeActionButton(Icons.add_circle_outline, 'Nueva receta', Colors.green[800]!),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: _buildFilterButton(),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.75, // Adjusted for responsiveness
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                _buildRecipeCard(context, 'Oleato de Rosas'),
                _buildRecipeCard(context, 'Agua de Florida'),
                _buildRecipeCard(context, 'Crema Urea para Pies'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 550,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF8B5E3C)),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.mic_none, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildLargeActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD2B48C).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5E3C).withOpacity(0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF8B5E3C)),
          SizedBox(width: 8),
          Text('Filtrar por ...', style: TextStyle(color: Color(0xFF8B5E3C), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, String title) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5E3C).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/logo_solluna.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1E4D0),
                      child: const Icon(Icons.menu_book, size: 50, color: Color(0xFF8B5E3C)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8B5E3C), size: 32),
      ],
    );
  }
}
