import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SaleItem> _currentSaleItems = [SaleItem()];
  final List<SaleRecord> _salesHistory = []; // Local history for demo
  
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalSale {
    double total = 0;
    for (var item in _currentSaleItems) {
      if (item.product != null) {
        total += item.product!.valor * item.quantity;
      }
    }
    return total;
  }

  void _addSaleItem() {
    setState(() {
      _currentSaleItems.add(SaleItem());
    });
  }

  void _removeSaleItem(int index) {
    if (_currentSaleItems.length > 1) {
      setState(() {
        _currentSaleItems.removeAt(index);
      });
    }
  }

  void _registrarVenta() {
    bool hasProduct = _currentSaleItems.any((item) => item.product != null);
    if (!hasProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor agrega al menos un producto')),
      );
      return;
    }

    final now = DateTime.now();
    final newRecord = SaleRecord(
      date: now,
      total: _totalSale,
      items: _currentSaleItems
          .where((i) => i.product != null)
          .map((i) => SaleRecordItem(name: i.product!.nombre, quantity: i.quantity, price: i.product!.valor))
          .toList(),
    );

    setState(() {
      _salesHistory.insert(0, newRecord);
      _currentSaleItems.clear();
      _currentSaleItems.add(SaleItem());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Venta registrada con éxito'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5E3C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF4E342E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ventas',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFF8B5E3C),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF8B5E3C),
                  tabs: const [
                    Tab(text: 'Registrar'),
                    Tab(text: 'Historial'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRegistroTab(),
              _buildHistorialTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistroTab() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Venta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa los productos vendidos',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSaleItemRow(index),
            ),
            childCount: _currentSaleItems.length,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSummarySection(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registrarVenta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('REGISTRAR VENTA', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorialTab() {
    final filteredSales = _selectedDateRange == null
        ? _salesHistory
        : _salesHistory.where((s) => s.date.isAfter(_selectedDateRange!.start) && s.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList();

    double historyTotal = filteredSales.fold(0, (sum, item) => sum + item.total);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ventas Registradas', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: Color(0xFF8B5E3C)),
                      onPressed: _selectDateRange,
                    ),
                  ],
                ),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Chip(
                      label: Text(
                        '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8B5E3C)),
                      ),
                      onDeleted: () => setState(() => _selectedDateRange = null),
                      deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF8B5E3C)),
                      backgroundColor: const Color(0xFFD2B48C).withOpacity(0.2),
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF8B5E3C).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text('TOTAL EN PERIODO', style: TextStyle(fontSize: 12, color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold)),
                      Text('\$$historyTotal', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        if (filteredSales.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('No hay ventas en este periodo', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                child: _buildHistoryExpandableCard(filteredSales[index]),
              ),
              childCount: filteredSales.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildSaleItemRow(int index) {
    final item = _currentSaleItems[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<Product>(
                  decoration: const InputDecoration(hintText: 'Producto', border: InputBorder.none),
                  value: item.product,
                  items: mockProducts.map((p) => DropdownMenuItem(value: p, child: Text(p.nombre, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (val) => setState(() => item.product = val),
                  isExpanded: true,
                ),
              ),
            ),
            Container(width: 1, height: 30, color: Colors.grey[200]),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: item.quantity.toString(),
                decoration: const InputDecoration(hintText: 'Cant.', border: InputBorder.none),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (val) => setState(() => item.quantity = int.tryParse(val) ?? 1),
              ),
            ),
            if (_currentSaleItems.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                onPressed: () => _removeSaleItem(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _addSaleItem,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text('Más productos'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5E3C)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('TOTAL', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text('\$$_totalSale', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryExpandableCard(SaleRecord record) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        shape: const Border(), // Remove default borders
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF8B5E3C).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(DateFormat('HH:mm').format(record.date), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
        ),
        title: Text(
          DateFormat('dd MMM, yyyy').format(record.date),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '\$${record.total}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: record.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: const TextStyle(fontSize: 13)),
                    Text('${item.quantity}x \$${item.price}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SaleRecord {
  final DateTime date;
  final double total;
  final List<SaleRecordItem> items;
  SaleRecord({required this.date, required this.total, required this.items});
}

class SaleRecordItem {
  final String name;
  final int quantity;
  final double price;
  SaleRecordItem({required this.name, required this.quantity, required this.price});
}

class SaleItem {
  Product? product;
  int quantity;
  SaleItem({this.product, this.quantity = 1});
}
