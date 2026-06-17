import '../models/product.dart';
import 'supabase_config.dart';

class ProductService {
  static const String tableName = 'productos_terminados';

  Stream<List<Product>> getProductsStream() {
    return SupabaseConfig.client
        .from(tableName)
        .stream(primaryKey: ['id'])
        .order('nombre', ascending: true)
        .map((maps) => maps.map((json) => Product.fromJson(json)).toList());
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
