import 'package:flutter/material.dart';
import '../widgets/filter_dialog.dart';
import '../services/ingredient_service.dart';
import '../models/ingredient.dart';

class InventarioIngredientesScreen extends StatefulWidget {
  const InventarioIngredientesScreen({super.key});

  @override
  State<InventarioIngredientesScreen> createState() => _InventarioIngredientesScreenState();
}

class _InventarioIngredientesScreenState extends State<InventarioIngredientesScreen> {
  final IngredientService _ingredientService = IngredientService();
  FilterOptions? _currentFilters;
  late Stream<List<Ingredient>> _ingredientsStream;

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  void _updateStream() {
    setState(() {
      _ingredientsStream = _ingredientService.getIngredientsStream(options: _currentFilters);
    });
  }

  void _showFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        type: FilterType.inventoryIngredients,
        onApply: (options) {
          setState(() {
            _currentFilters = options;
            _updateStream();
          });
        },
      ),
    );
  }

  Future<void> _confirmDelete(Ingredient ingredient) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${ingredient.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && ingredient.id != null) {
      try {
        await _ingredientService.deleteIngredient(ingredient.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrediente eliminado con éxito'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(Ingredient ingredient) async {
    final nombreController = TextEditingController(text: ingredient.nombre);
    final categoriaController = TextEditingController(text: ingredient.categoria);
    final stockController = TextEditingController(text: ingredient.cantidadRestante.toString());
    final unidadController = TextEditingController(text: ingredient.unidadMedida);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Ingrediente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: categoriaController, decoration: const InputDecoration(labelText: 'Categoría')),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
              TextField(controller: unidadController, decoration: const InputDecoration(labelText: 'Unidad (g, ml, U)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final updatedIngredient = Ingredient(
                id: ingredient.id,
                nombre: nombreController.text,
                categoria: categoriaController.text,
                cantidadRestante: double.tryParse(stockController.text) ?? ingredient.cantidadRestante,
                unidadMedida: unidadController.text,
                alertaStockBajo: ingredient.alertaStockBajo,
              );
              
              try {
                await _ingredientService.updateIngredient(updatedIngredient);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrediente actualizado'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5E3C), foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
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
            'Inventario Ingredientes',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallIconButton(context, Icons.filter_alt_outlined, (_) => _showFilter(context), "Filtrar", const Color(0xFFD2B48C)),
              if (_currentFilters != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: () => setState(() {
                      _currentFilters = null;
                      _updateStream();
                    }),
                  ),
                ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {}, 
                icon: const Icon(Icons.add_to_photos_outlined, size: 18),
                label: const Text('Agregar'),
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
            child: StreamBuilder<List<Ingredient>>(
              stream: _ingredientsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E3C)));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error al cargar insumos: ${snapshot.error}'),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay ingredientes en el inventario.'));
                }

                final ingredients = snapshot.data!;
                return ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return _buildIngredientItem(ingredient);
                  },
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
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF8B5E3C)),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar ingredientes...',
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

  Widget _buildIngredientItem(Ingredient ingredient) {
    final alert = ingredient.cantidadRestante <= ingredient.alertaStockBajo ? (ingredient.cantidadRestante == 0 ? '¡Sin Stock!' : 'Por agotar') : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF8B5E3C).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('ID: ${ingredient.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C), fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(ingredient.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(onPressed: () => _showEditDialog(ingredient), icon: const Icon(Icons.mode_edit_outline_outlined, color: Colors.orange, size: 20)),
                IconButton(onPressed: () => _confirmDelete(ingredient), icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 20)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    Text(ingredient.categoria, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Restante', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    Text('${ingredient.cantidadRestante} ${ingredient.unidadMedida}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8B5E3C))),
                  ],
                ),
                if (alert != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.contains('Sin') ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: alert.contains('Sin') ? const Color(0xFFFFCDD2) : const Color(0xFFFFE0B2)),
                    ),
                    child: Text(
                      alert,
                      style: TextStyle(color: alert.contains('Sin') ? const Color(0xFFB71C1C) : const Color(0xFFE65100), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
