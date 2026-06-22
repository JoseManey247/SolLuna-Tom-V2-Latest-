import '../models/ingredient.dart';
import '../widgets/filter_dialog.dart';
import 'supabase_config.dart';

class IngredientService {
  static const String tableName = 'insumos';

  Stream<List<Ingredient>> getIngredientsStream({FilterOptions? options, String? search}) {
    var query = SupabaseConfig.client.from(tableName).stream(primaryKey: ['id']);

    String col = 'nombre';
    bool asc = true;

    if (options != null) {
      if (options.orderType == 'id_desc') {
        col = 'id';
        asc = false;
      } else {
        if (options.selectedFields.isNotEmpty) {
          String first = options.selectedFields.first;
          if (first.contains('Stock')) col = 'cantidad_restante';
          if (first.contains('Categoria')) col = 'categoria';
        }
        asc = (options.orderType == 'az' || options.orderType == 'low');
      }
    }

    return query.order(col, ascending: asc).map((maps) {
      var list = maps.map((json) => Ingredient.fromJson(json)).toList();
      
      // Filter by search term
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        list = list.where((i) => 
          i.nombre.toLowerCase().contains(query) || 
          i.categoria.toLowerCase().contains(query)
        ).toList();
      }

      // Date filtering if needed (stream side)
      if (options?.startDate != null) {
        // created_at filtering is usually better done on server, 
        // but for streams we filter locally or use a different approach if many records
        // For now, let's assume we don't filter dates on ingredients unless requested for a history
      }
      return list;
    });
  }

  Future<List<Ingredient>> getIngredients() async {
    final response = await SupabaseConfig.client
        .from(tableName)
        .select()
        .order('nombre', ascending: true);
    
    return (response as List).map((json) => Ingredient.fromJson(json)).toList();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await SupabaseConfig.client.from(tableName).insert(ingredient.toJson());
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    if (ingredient.id == null) return;
    await SupabaseConfig.client
        .from(tableName)
        .update(ingredient.toJson())
        .eq('id', ingredient.id!);
  }

  Future<void> deleteIngredient(int id) async {
    await SupabaseConfig.client.from(tableName).delete().eq('id', id);
  }
}
