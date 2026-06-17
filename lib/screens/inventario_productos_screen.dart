import 'package:flutter/material.dart';
import '../widgets/filter_dialog.dart';

class InventarioProductosScreen extends StatelessWidget {
  const InventarioProductosScreen({super.key});

  void _showFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(type: FilterType.inventoryProducts),
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
            'Inventario Productos',
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
                label: const Text('Agregar'),
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
                _buildInventoryItem('1', 'Crema Urea al 20%', 'Cremas', '28 U', null),
                _buildInventoryItem('2', 'Aceite de Cannabis', 'Aceites', '12 U', 'Por agotar'),
                _buildInventoryItem('3', 'Jabón Carbón Activado', 'Jabones', '0 U', '¡Sin Stock!'),
                _buildInventoryItem('4', 'Agua de Florida', 'Colonias', '5 U', 'Por agotar'),
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
                hintText: 'Buscar en el inventario...',
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

  Widget _buildInventoryItem(String id, String name, String category, String stock, String? alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF8B5E3C).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('ID: $id', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C), fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Actual', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    Text(stock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8B5E3C))),
                  ],
                ),
                if (alert != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.contains('Sin') ? Colors.red[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: alert.contains('Sin') ? Colors.red[200]! : Colors.orange[200]!),
                    ),
                    child: Text(
                      alert,
                      style: TextStyle(color: alert.contains('Sin') ? Colors.red[900] : Colors.orange[900], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
