import '../models/product.dart';
import '../widgets/filter_dialog.dart';
import 'supabase_config.dart';

class ProductService {
  static const String tableName = 'productos_terminados';

  Stream<List<Product>> getProductsStream({FilterOptions? options}) {
    var query = SupabaseConfig.client.from(tableName).stream(primaryKey: ['id']);

    // Map high-level orderType to DB columns
    String col = 'nombre';
    bool asc = true;

    if (options != null) {
      if (options.orderType == 'id_desc') {
        col = 'id';
        asc = false;
      } else {
        // Logic for single selection
        if (options.selectedFields.isNotEmpty) {
          String first = options.selectedFields.first;
          if (first.contains('Precio')) col = 'precio_venta';
          if (first.contains('Stock')) col = 'stock_unidades';
          if (first.contains('Categoria')) col = 'categoria';
        }
        asc = (options.orderType == 'az' || options.orderType == 'low');
      }
    }

    return query.order(col, ascending: asc).map((maps) {
      var list = maps.map((json) => Product.fromJson(json)).toList();
      
      // Price Range filter (client side for streams usually easier or use RPC/Rest for complex server filtering)
      if (options?.priceRange != null) {
        list = list.where((p) => p.valor >= options!.priceRange!.start && p.valor <= options.priceRange!.end).toList();
      }
      return list;
    });
  }

  Future<List<Product>> getProducts() async {
    final response = await SupabaseConfig.client
        .from(tableName)
        .select()
        .order('nombre', ascending: true);
    
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<void> addProduct(Product product) async {
    await SupabaseConfig.client.from(tableName).insert(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) return;
    await SupabaseConfig.client
        .from(tableName)
        .update(product.toJson())
        .eq('id', product.id!);
  }

  Future<void> deleteProduct(int id) async {
    await SupabaseConfig.client.from(tableName).delete().eq('id', id);
  }

  Future<void> updateStock(int productId, int newStock) async {
    await SupabaseConfig.client
        .from(tableName)
        .update({'stock_unidades': newStock})
        .eq('id', productId);
  }
}
