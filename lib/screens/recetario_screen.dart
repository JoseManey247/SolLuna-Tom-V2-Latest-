import 'package:flutter/material.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/add_recipe_dialog.dart';
import '../services/recipe_service.dart';
import '../models/recipe.dart';

class RecetarioScreen extends StatefulWidget {
  const RecetarioScreen({super.key});

  @override
  State<RecetarioScreen> createState() => _RecetarioScreenState();
}

class _RecetarioScreenState extends State<RecetarioScreen> {
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _refreshRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshRecipes() {
    setState(() {
      _recipesFuture = _recipeService.getRecipes(search: _searchController.text);
    });
  }

  void _showFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FilterDialog(type: FilterType.recipe),
    );
  }

  void _showRecipeDetail(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipeDetailSheet(recipe: recipe),
    );
  }

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddRecipeDialog(
        onSave: (newRecipe) async {
          try {
            await _recipeService.addRecipe(newRecipe);
            _refreshRecipes();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receta guardada con éxito'), backgroundColor: Colors.green),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar receta: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recetario Maestro',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallIconButton(context, Icons.filter_alt_outlined, (_) => _showFilter(context), "Filtrar", const Color(0xFFD2B48C)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddRecipeDialog,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Nueva Receta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E3C)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay recetas guardadas.'));
                }

                final recipes = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async => _refreshRecipes(),
                  child: ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeItem(recipes[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFD2B48C).withOpacity(0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8B5E3C)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _refreshRecipes(),
              decoration: const InputDecoration(
                hintText: 'Buscar recetas...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconButton(BuildContext context, IconData icon, Function(BuildContext) onTap, String label, Color color) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8B5E3C)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItem(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
      child: InkWell(
        onTap: () => _showRecipeDetail(recipe),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined, color: Color(0xFF8B5E3C), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Base: ${recipe.pesoBase}g',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${recipe.ingredients.length} Ingredientes',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  const SizedBox(height: 12),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeDetailSheet extends StatelessWidget {
  final Recipe recipe;

  const _RecipeDetailSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFFDF5E6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(recipe.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          const Text('Ingredientes y Fórmulas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildInfoRow('Peso Base Total', '${recipe.pesoBase} g'),
                const SizedBox(height: 20),
                ...recipe.ingredients.map((ing) => _buildIngredientTile(ing)),
                const SizedBox(height: 24),
                const Text('Instrucciones de Preparación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
                  child: Text(
                    recipe.instrucciones.isEmpty ? 'Sin instrucciones registradas.' : recipe.instrucciones,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C))),
      ],
    );
  }

  Widget _buildIngredientTile(RecipeIngredient ing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD2B48C).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFD2B48C).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(ing.fase, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5E3C))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ing.nombreInsumo ?? 'Insumo desconocido', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${ing.porcentaje}% de la fórmula', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Text('${ing.gramos} g', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4E342E))),
        ],
      ),
    );
  }
}
