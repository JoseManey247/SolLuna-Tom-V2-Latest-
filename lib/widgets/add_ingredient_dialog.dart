import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class AddIngredientDialog extends StatefulWidget {
  final Function(Ingredient) onSave;

  const AddIngredientDialog({super.key, required this.onSave});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Insumo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre del ingrediente'),
            enabled: !_isSaving,
          ),
          TextField(
            controller: _categoriaController,
            decoration: const InputDecoration(labelText: 'Categoría (Ej: Aceites, Activos...)'),
            enabled: !_isSaving,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context), 
          child: const Text('Cancelar')
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : () async {
            if (_nombreController.text.isNotEmpty) {
              setState(() => _isSaving = true);
              final newIng = Ingredient(
                nombre: _nombreController.text,
                categoria: _categoriaController.text,
                cantidadRestante: 0,
                unidadMedida: 'g',
                alertaStockBajo: 0,
              );
              await widget.onSave(newIng);
              if (mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C), 
            foregroundColor: Colors.white
          ),
          child: _isSaving 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Guardar'),
        ),
      ],
    );
  }
}
