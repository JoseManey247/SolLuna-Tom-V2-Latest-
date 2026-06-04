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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Inventario Productos',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildFilterButton(context),
              const Spacer(),
              _buildActionButton('Eliminar', Colors.red[900]!, Icons.delete_outline),
              const SizedBox(width: 12),
              _buildActionButton('Modificar', Colors.orange[800]!, Icons.edit_outlined),
              const SizedBox(width: 12),
              _buildActionButton('Agregar', Colors.green[800]!, Icons.add_circle_outline),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildInventoryTable(),
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
              ),
            ),
          ),
          Icon(Icons.mic_none, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return InkWell(
      onTap: () => _showFilter(context),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD2B48C).withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF8B5E3C).withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 20, color: Color(0xFF8B5E3C)),
            SizedBox(width: 8),
            Text('Filtrar', style: TextStyle(color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInventoryTable() {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1),
          3: IntrinsicColumnWidth(),
          4: FlexColumnWidth(1.8),
          5: FlexColumnWidth(1.2),
        },
        children: [
          _buildTableHeader(),
          _buildTableRow('1', 'Crema Urea al 20%', 'Cremas', '28 U', 'Reparadora de piel seca y extra...', null, true),
          _buildTableRow('2', 'Crema Urea al 20%', 'Cremas', '12 U', 'Reparadora de piel seca y extra...', 'Por agotar', false),
          _buildTableRow('3', 'Crema Urea al 20%', 'Cremas', '0 U', 'Reparadora de piel seca y extra...', '¡Sin Stock!', true),
          _buildTableRow('4', '-', '-', '-', '-', null, false),
          _buildTableRow('5', '-', '-', '-', '-', null, true),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFF8B5E3C)),
      children: [
        _headerCell('ID'),
        _headerCell('Nombre'),
        _headerCell('Categoría'),
        _headerCell('Stock'),
        _headerCell('Descripción'),
        _headerCell('Alertas'),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  TableRow _buildTableRow(String id, String name, String cat, String stock, String desc, String? alert, bool isEven) {
    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : const Color(0xFFF1E4D0).withOpacity(0.3),
      ),
      children: [
        _dataCell(id),
        _dataCell(name, isItalic: true),
        _dataCell(cat),
        _dataCell(stock),
        _dataCell(desc, isItalic: true),
        Padding(
          padding: const EdgeInsets.all(12),
          child: alert == null
              ? const SizedBox()
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: alert.contains('Sin') ? Colors.red[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: alert.contains('Sin') ? Colors.red[200]! : Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        alert.contains('Sin') ? Icons.error_outline : Icons.warning_amber_rounded,
                        color: alert.contains('Sin') ? Colors.red[900] : Colors.orange[900],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          alert,
                          style: TextStyle(
                            color: alert.contains('Sin') ? Colors.red[900] : Colors.orange[900],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _dataCell(String text, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: const Color(0xFF5D4037),
        ),
      ),
    );
  }
}
