import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/product.dart';
import '../services/ingredient_service.dart';
import '../services/product_service.dart';

class AddRecipeDialog extends StatefulWidget {
  final Function(Recipe) onSave;

  const AddRecipeDialog({super.key, required this.onSave});

  @override
  State<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends State<AddRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  
  int? _selectedProductId;
  List<Product> _products = [];
  List<Ingredient> _availableIngredients = [];
  final List<RecipeIngredientFormModel> _ingredientsRows = [];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _addIngredientRow();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final products = await ProductService().getProducts();
      final ingredients = await IngredientService().getIngredients();
      setState(() {
        _products = products;
        _availableIngredients = ingredients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  double get _totalGramos {
    return _ingredientsRows.fold(0.0, (sum, item) => sum + item.gramos);
  }

  void _addIngredientRow() {
    setState(() {
      String nextPhase = 'A';
      if (_ingredientsRows.isNotEmpty) {
        nextPhase = _ingredientsRows.last.fase;
      }
      _ingredientsRows.add(RecipeIngredientFormModel(fase: nextPhase));
    });
  }

  void _removeIngredientRow(int index) {
    if (_ingredientsRows.length > 1) {
      setState(() {
        _ingredientsRows.removeAt(index);
      });
    }
  }

  Widget _buildStepFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Procedimiento (Pasos)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._stepControllers.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF8B5E3C),
                  child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      hintText: 'Ej: Desinfección de utensilios...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (_stepControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => setState(() => _stepControllers.removeAt(idx)),
                  ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: _addStep,
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Agregar Paso'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFDF5E6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.all(24),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nueva Receta Maestra', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24)),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Producto Final Vinculado', border: OutlineInputBorder()),
                      initialValue: _selectedProductId,
                      items: _products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                      onChanged: (val) => setState(() => _selectedProductId = val),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre de la Receta', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5E3C).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Peso Total: ${_totalGramos.toStringAsFixed(1)}g',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    ..._ingredientsRows.asMap().entries.map((entry) => _buildIngredientRow(entry.key, entry.value)),

                    TextButton.icon(
                      onPressed: _addIngredientRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Insumo'),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildStepFields(),
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('Guardar Receta'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildIngredientRow(int index, RecipeIngredientFormModel model) {
    double perc = _totalGramos > 0 ? (model.gramos / _totalGramos) * 100 : 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: DropdownButtonFormField<String>(
                    value: model.fase,
                    decoration: const InputDecoration(labelText: 'Fase'),
                    items: ['A', 'B', 'C', 'D'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (v) => setState(() => model.fase = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: model.insumoId,
                    decoration: const InputDecoration(labelText: 'Ingrediente'),
                    items: _availableIngredients.map((i) => DropdownMenuItem(value: i.id, child: Text(i.nombre))).toList(),
                    onChanged: (v) => setState(() => model.insumoId = v),
                  ),
                ),
                IconButton(onPressed: () => _removeIngredientRow(index), icon: const Icon(Icons.delete, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Función (Ej: Activo, Emulsionante, Conservante...)',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => model.funcion = v,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: model.gramos > 0 ? model.gramos.toString() : '',
                    decoration: const InputDecoration(labelText: 'Peso (g)', hintText: '0.0'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => setState(() => model.gramos = double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${perc.toStringAsFixed(2)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Unir los pasos en un solo texto con numeración
      String instruccionesFinales = _stepControllers.asMap().entries
          .where((e) => e.value.text.isNotEmpty)
          .map((e) => '${e.key + 1}) ${e.value.text}')
          .join('\n');

      final recipe = Recipe(
        productoId: _selectedProductId,
        nombre: _nombreController.text,
        pesoBase: _totalGramos,
        instrucciones: instruccionesFinales,
        ingredients: _ingredientsRows.where((r) => r.insumoId != null).map((r) => RecipeIngredient(
          insumoId: r.insumoId!,
          fase: r.fase,
          funcion: r.funcion, // Guardar función
          porcentaje: _totalGramos > 0 ? (r.gramos / _totalGramos) * 100 : 0,
          gramos: r.gramos,
        )).toList(),
      );
      widget.onSave(recipe);
      Navigator.pop(context);
    }
  }
}

class RecipeIngredientFormModel {
  String fase;
  int? insumoId;
  String funcion = ''; // Nueva propiedad
  double gramos = 0;

  RecipeIngredientFormModel({this.fase = 'A'});
}
