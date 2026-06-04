import 'package:flutter/material.dart';

class VentasScreen extends StatelessWidget {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ventas',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton('Consultas en tiempo real'),
                _buildActionButton('Método de fidelización de clientes calendarizadas'),
                _buildActionButton('Dashboards'),
                _buildActionButton('Generar venta'),
                _buildActionButton('Generar Reporte de ventas (último mes)'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildFilterButton(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD2B48C).withOpacity(0.5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildSalesTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: 160,
      height: 90,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC4A484), Color(0xFF8B5E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5E3C).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
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
          Text(
            'Filtrar por ...',
            style: TextStyle(color: Color(0xFF8B5E3C), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTable() {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1),
        },
        children: [
          _buildTableHeader(),
          _buildTableRow('Hoy, 14:30', 'María de Concepción', '1x Crema Urea\ny 3 productos más ...', '\$18.500', true),
          _buildTableRow('Ayer, 18:15', 'Entrega en Tomé Centro', '2x Jabón de Avena', '\$9.000', false),
          _buildTableRow('28 May, 11:00', 'Sin nota', '1x Sérum Facial', '\$15.000', true),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFD2B48C)),
      children: [
        _headerCell('Fecha / Hora'),
        _headerCell('Cliente / Nota'),
        _headerCell('Productos'),
        _headerCell('Total'),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5D4037)),
      ),
    );
  }

  TableRow _buildTableRow(String col1, String col2, String col3, String col4, bool isEven) {
    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : const Color(0xFFFDF5E6).withOpacity(0.5),
      ),
      children: [
        _dataCell(col1),
        _dataCell(col2),
        _dataCell(col3),
        _dataCell(col4, isBold: true),
      ],
    );
  }

  Widget _dataCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: const Color(0xFF5D4037),
        ),
      ),
    );
  }
}
