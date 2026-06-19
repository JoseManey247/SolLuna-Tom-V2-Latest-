import 'supabase_config.dart';
import '../models/recipe.dart';

class RecipeService {
  static const String tableName = 'formulas';

  Future<List<Recipe>> getRecipes() async {
    final response = await SupabaseConfig.client
        .from(tableName)
        .select('*, formula_detalle(*, insumos(nombre))')
        .order('nombre_formula', ascending: true);
    
    return (response as List).map((json) => Recipe.fromJson(json)).toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await SupabaseConfig.client.from(tableName).insert(recipe.toJson());
  }

  Future<void> deleteRecipe(int id) async {
    await SupabaseConfig.client.from(tableName).delete().eq('id', id);
  }
}
