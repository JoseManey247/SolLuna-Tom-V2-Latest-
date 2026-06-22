import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale_record_model.dart';
import '../services/product_service.dart';
import '../services/sales_service.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProductService _productService = ProductService();
  final SalesService _salesService = SalesService();

  final List<SaleItem> _currentSaleItems = [SaleItem()];
  List<Product> _availableProducts = [];
  bool _isLoadingProducts = true;

  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _availableProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalSale {
    int total = 0;
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

  Future<void> _registrarVenta() async {
    bool hasProduct = _currentSaleItems.any((item) => item.product != null);
    if (!hasProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor agrega al menos un producto')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E3C))),
      );

      final now = DateTime.now();
      
      // We process each item as a separate record in the database for simplicity of the schema shared
      for (var item in _currentSaleItems.where((i) => i.product != null)) {
        final record = SaleRecordModel(
          productoId: item.product!.id!,
          cantidadVendida: item.quantity,
          totalVenta: (item.product!.valor * item.quantity).toInt(),
          createdAt: now,
        );
        await _salesService.registerSale(record);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() {
          _currentSaleItems.clear();
          _currentSaleItems.add(SaleItem());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta registrada y stock actualizado'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar venta: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E3C)));
    }

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
              Row(
                children: [
                  Expanded(
                    child: _buildModeButton(
                      label: 'Registrar',
                      isActive: _tabController.index == 0,
                      onTap: () => setState(() => _tabController.animateTo(0)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeButton(
                      label: 'Historial',
                      isActive: _tabController.index == 1,
                      onTap: () => setState(() => _tabController.animateTo(1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
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
                Text('Nueva Venta', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Ingresa los productos vendidos', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _salesService.getSalesHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E3C)));
        }

        final allSales = snapshot.data ?? [];
        
        // Group sales by date
        final Map<String, List<Map<String, dynamic>>> groupedSales = {};
        for (var sale in allSales) {
          final date = DateTime.parse(sale['created_at']).toLocal();
          final dateStr = DateFormat('yyyy-MM-dd').format(date);
          if (!groupedSales.containsKey(dateStr)) {
            groupedSales[dateStr] = [];
          }
          groupedSales[dateStr]!.add(sale);
        }

        final sortedDates = groupedSales.keys.toList()..sort((a, b) => b.compareTo(a));

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registro de Ventas Diario', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Acumulado por fecha', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (sortedDates.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('No hay ventas registradas', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dateStr = sortedDates[index];
                    final daySales = groupedSales[dateStr]!;
                    final totalDay = daySales.fold(0, (sum, item) => sum + ((item['total_venta'] as num?)?.toInt() ?? 0));
                    final dateObj = DateTime.parse(dateStr);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), 
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5E3C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_today, color: Color(0xFF8B5E3C), size: 20),
                          ),
                          title: Text(
                            DateFormat('EEEE dd/MM/yyyy', 'es_ES').format(dateObj).capitalize(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text('${daySales.length} ventas realizadas'),
                          trailing: Text(
                            '\$${NumberFormat('#,###', 'es_CL').format(totalDay)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18),
                          ),
                          children: daySales.map((sale) {
                            final saleTime = DateTime.parse(sale['created_at']).toLocal();
                            final prodName = sale['productos_terminados']['nombre'];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey[100]!)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(saleTime),
                                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(prodName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        Text('${sale['cantidad_vendida']} unidades', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${NumberFormat('#,###', 'es_CL').format(sale['total_venta'])}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  childCount: sortedDates.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }
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
                  initialValue: item.product,
                  items: _availableProducts.map((p) => DropdownMenuItem(value: p, child: Text(p.nombre, style: const TextStyle(fontSize: 14)))).toList(),
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


  Widget _buildModeButton({required String label, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B5E3C) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF8B5E3C)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF8B5E3C),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class SaleItem {
  Product? product;
  int quantity;
  SaleItem({this.product, this.quantity = 1});
}
