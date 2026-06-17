import '../models/ingredient.dart';
import 'supabase_config.dart';

class IngredientService {
  static const String tableName = 'insumos';

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
