import 'package:flutter/material.dart';
import '../widgets/filter_dialog.dart';

class RecetarioScreen extends StatelessWidget {
  const RecetarioScreen({super.key});

  void _showFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(type: FilterType.recipe),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recetario Maestro',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallIconButton(context, Icons.filter_alt_outlined, _showFilter, "Filtrar", const Color(0xFFD2B48C)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Nueva Receta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildRecipeItem('Oleato de Rosas', 'Base Aceite', '2.5% de activos'),
                _buildRecipeItem('Agua de Florida', 'Alcoholes', 'Esencias varias'),
                _buildRecipeItem('Crema Urea para Pies', 'Cremas', '20% Urea activa'),
                _buildRecipeItem('Jabón de Carbón', 'Jabones', 'Limpieza profunda'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD2B48C).withOpacity(0.5)),
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
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton(BuildContext context, IconData icon, Function(BuildContext) onTap, String label, Color color) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8B5E3C)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItem(String title, String category, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5E3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_outlined, color: Color(0xFF8B5E3C), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                const SizedBox(height: 12),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
