import 'supabase_config.dart';
import '../models/recipe.dart';

class RecipeService {
  static const String tableName = 'formulas';

  Future<List<Recipe>> getRecipes({String? search}) async {
    var query = SupabaseConfig.client
        .from(tableName)
        .select('*, formula_detalle(*, insumos(nombre))');

    if (search != null && search.isNotEmpty) {
      query = query.ilike('nombre_formula', '%$search%');
    }

    final response = await query.order('nombre_formula', ascending: true);
    
    return (response as List).map((json) => Recipe.fromJson(json)).toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    // 1. Insert formula and get ID
    final recipeResponse = await SupabaseConfig.client
        .from(tableName)
        .insert(recipe.toJson())
        .select()
        .single();
    
    final recipeId = recipeResponse['id'];

    // 2. Insert ingredients details
    if (recipe.ingredients.isNotEmpty) {
      final details = recipe.ingredients.map((ing) => {
        'formula_id': recipeId,
        'insumo_id': ing.insumoId,
        'fase': ing.fase,
        'funcion': ing.funcion, // Envía la función
        'porcentaje': ing.porcentaje,
        'gramos_base': ing.gramos,
      }).toList();

      await SupabaseConfig.client.from('formula_detalle').insert(details);
    }
  }

  Future<void> deleteRecipe(int id) async {
    await SupabaseConfig.client.from(tableName).delete().eq('id', id);
  }
}
