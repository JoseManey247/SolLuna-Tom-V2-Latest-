import '../models/sale_record_model.dart';
import 'supabase_config.dart';
import 'product_service.dart';

class SalesService {
  static const String tableName = 'ventas_registro';
  final ProductService _productService = ProductService();

  Future<void> registerSale(SaleRecordModel sale) async {
    // 1. Save the sale record
    await SupabaseConfig.client.from(tableName).insert(sale.toJson());

    // 2. Fetch current stock of the product
    final productResponse = await SupabaseConfig.client
        .from('productos_terminados')
        .select('stock_unidades')
        .eq('id', sale.productoId)
        .single();
    
    int currentStock = productResponse['stock_unidades'] ?? 0;

    // 3. Update the stock
    int newStock = currentStock - sale.cantidadVendida;
    if (newStock < 0) newStock = 0; // Prevent negative stock

    await _productService.updateStock(sale.productoId, newStock);
  }

  Future<List<Map<String, dynamic>>> getSalesHistory() async {
    // Joining with productos_terminados to get the product name
    final response = await SupabaseConfig.client
        .from(tableName)
        .select('*, productos_terminados(nombre)')
        .order('created_at', ascending: false);
    
    return response;
  }

  Future<double> getMonthlySalesTotal() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    
    final response = await SupabaseConfig.client
        .from(tableName)
        .select('total_venta')
        .gte('created_at', startOfMonth);
    
    double total = 0;
    for (var item in response) {
      total += (item['total_venta'] as num).toDouble();
    }
    return total;
  }
}
