import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale_record_model.dart';
import '../services/product_service.dart';
import '../services/sales_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

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
        
        // Group sales by Month, then by Day
        final Map<String, Map<String, List<Map<String, dynamic>>>> groupedByMonth = {};
        
        for (var sale in allSales) {
          final date = DateTime.parse(sale['created_at']).toLocal();
          final monthStr = DateFormat('MMMM yyyy', 'es_ES').format(date).capitalize();
          final dayStr = DateFormat('yyyy-MM-dd').format(date);
          
          if (!groupedByMonth.containsKey(monthStr)) {
            groupedByMonth[monthStr] = {};
          }
          if (!groupedByMonth[monthStr]!.containsKey(dayStr)) {
            groupedByMonth[monthStr]![dayStr] = [];
          }
          groupedByMonth[monthStr]![dayStr]!.add(sale);
        }

        final sortedMonths = groupedByMonth.keys.toList()..sort((a, b) {
          // Sort months descending (parse back to compare properly)
          final dateA = DateFormat('MMMM yyyy', 'es_ES').parse(a);
          final dateB = DateFormat('MMMM yyyy', 'es_ES').parse(b);
          return dateB.compareTo(dateA);
        });

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Historial de Ventas', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text('Agrupado por mes y día', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                        _buildExportButton(allSales),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (sortedMonths.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('No hay ventas registradas', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final monthStr = sortedMonths[index];
                    final daysInMonth = groupedByMonth[monthStr]!;
                    final sortedDays = daysInMonth.keys.toList()..sort((a, b) => b.compareTo(a));
                    
                    int totalMonth = 0;
                    daysInMonth.forEach((day, sales) {
                      totalMonth += sales.fold(0, (sum, s) => sum + ((s['total_venta'] as num?)?.toInt() ?? 0));
                    });

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF8B5E3C).withValues(alpha: 0.1)),
                        ),
                        child: ExpansionTile(
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          shape: const Border(),
                          iconColor: const Color(0xFF8B5E3C),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF8B5E3C).withValues(alpha: 0.1),
                            child: const Icon(Icons.calendar_month, color: Color(0xFF8B5E3C), size: 20),
                          ),
                          title: Text(
                            monthStr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)),
                          ),
                          subtitle: Text('\$${NumberFormat('#,###', 'es_CL').format(totalMonth)} acumulado'),
                          children: sortedDays.map((dayStr) {
                            final daySales = daysInMonth[dayStr]!;
                            final dateObj = DateTime.parse(dayStr);
                            final totalDay = daySales.fold(0, (sum, item) => sum + ((item['total_venta'] as num?)?.toInt() ?? 0));

                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Card(
                                elevation: 0,
                                color: const Color(0xFFFDF5E6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: Colors.grey[200]!),
                                ),
                                child: ExpansionTile(
                                  shape: const Border(),
                                  title: Text(
                                    DateFormat('EEEE dd', 'es_ES').format(dateObj).capitalize(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  trailing: Text(
                                    '\$${NumberFormat('#,###', 'es_CL').format(totalDay)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                  children: daySales.map((sale) {
                                    final saleTime = DateTime.parse(sale['created_at']).toLocal();
                                    final prodName = sale['productos_terminados']['nombre'];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        border: Border(top: BorderSide(color: Colors.grey[100]!)),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat('HH:mm').format(saleTime),
                                            style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(prodName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                          ),
                                          Text(
                                            '\$${NumberFormat('#,###', 'es_CL').format(sale['total_venta'])}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  childCount: sortedMonths.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }
    );
  }

  Widget _buildExportButton(List<Map<String, dynamic>> allSales) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.file_download_outlined, color: Color(0xFF8B5E3C)),
      tooltip: 'Exportar Reporte',
      onSelected: (val) => _exportToCSV(val, allSales),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'diario', child: Text('Reporte Diario (Hoy)')),
        const PopupMenuItem(value: 'semanal', child: Text('Reporte Semanal (Últ. 7 días)')),
        const PopupMenuItem(value: 'mensual', child: Text('Reporte Mensual (Este mes)')),
        const PopupMenuItem(value: 'anual', child: Text('Reporte Anual (Este año)')),
        const PopupMenuItem(value: 'todo', child: Text('Todo el Historial')),
      ],
    );
  }

  Future<void> _exportToCSV(String range, List<Map<String, dynamic>> allSales) async {
    final now = DateTime.now();
    List<Map<String, dynamic>> filteredSales = [];
    
    switch (range) {
      case 'diario':
        filteredSales = allSales.where((s) => 
          DateFormat('yyyy-MM-dd').format(DateTime.parse(s['created_at']).toLocal()) == 
          DateFormat('yyyy-MM-dd').format(now)).toList();
        break;
      case 'semanal':
        final weekAgo = now.subtract(const Duration(days: 7));
        filteredSales = allSales.where((s) => DateTime.parse(s['created_at']).isAfter(weekAgo)).toList();
        break;
      case 'mensual':
        filteredSales = allSales.where((s) {
          final d = DateTime.parse(s['created_at']);
          return d.year == now.year && d.month == now.month;
        }).toList();
        break;
      case 'anual':
        filteredSales = allSales.where((s) => DateTime.parse(s['created_at']).year == now.year).toList();
        break;
      default:
        filteredSales = allSales;
    }

    if (filteredSales.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay datos para exportar en este periodo')));
      }
      return;
    }

    // Prepare data for CSV
    List<List<dynamic>> rows = [];
    rows.add(['Fecha', 'Hora', 'Producto', 'Cantidad', 'Total (\$)']);
    
    for (var sale in filteredSales) {
      final date = DateTime.parse(sale['created_at']).toLocal();
      rows.add([
        DateFormat('dd/MM/yyyy').format(date),
        DateFormat('HH:mm').format(date),
        sale['productos_terminados']['nombre'],
        sale['cantidad_vendida'],
        sale['total_venta'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    String fileName = "reporte_ventas_${range}_${DateFormat('yyyyMMdd').format(now)}.csv";

    try {
      if (!kIsWeb && Platform.isWindows) {
        // --- LOGIC FOR PC (Windows) ---
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar Reporte de Ventas',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsString(csvData);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reporte guardado con éxito'), backgroundColor: Colors.green),
            );
          }
        }
      } else {
        // --- LOGIC FOR MOBILE (Android/iOS) ---
        final directory = await getTemporaryDirectory();
        final path = "${directory.path}/$fileName";
        final file = File(path);
        await file.writeAsString(csvData);

        if (mounted) {
          final result = await Share.shareXFiles(
            [XFile(path)],
            text: 'Reporte de Ventas SolLuna ($range)',
            subject: 'Reporte de Ventas',
          );

          if (result.status == ShareResultStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reporte exportado con éxito'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar reporte: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
