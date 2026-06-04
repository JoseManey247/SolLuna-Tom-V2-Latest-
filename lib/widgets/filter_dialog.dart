import 'package:flutter/material.dart';

enum FilterType { catalog, inventoryProducts, inventoryIngredients }

class FilterDialog extends StatefulWidget {
  final FilterType type;

  const FilterDialog({super.key, required this.type});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  double _priceRange = 50000;
  final Map<String, bool> _checkboxes = {};

  @override
  void initState() {
    super.initState();
    _initCheckboxes();
  }

  void _initCheckboxes() {
    _checkboxes['Por nombre (A-Z / Z-A)'] = false;
    _checkboxes['Por categoría/tipo (A-Z / Z-A)'] = false;
    _checkboxes['Por precio (Mayor a menor / Viceversa)'] = false;
    _checkboxes['Por cantidad en stock (Mayor a menor / Viceversa)'] = false;

    if (widget.type == FilterType.inventoryProducts || widget.type == FilterType.inventoryIngredients) {
      _checkboxes['Por ID (Mayor a menor / Viceversa)'] = false;
      _checkboxes['Alerta: Por Agotar'] = false;
      _checkboxes['Alerta: Sin Stock'] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtrar ${_getTitle()}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._checkboxes.keys.map((key) {
              return CheckboxListTile(
                title: Text(key),
                value: _checkboxes[key],
                onChanged: (val) {
                  setState(() => _checkboxes[key] = val!);
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF8B5E3C),
              );
            }),
            const SizedBox(height: 16),
            const Text('Rango de precio:', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _priceRange,
              min: 0,
              max: 100000,
              divisions: 100,
              label: '\$${_priceRange.round()}',
              activeColor: const Color(0xFF8B5E3C),
              onChanged: (val) {
                setState(() => _priceRange = val);
              },
            ),
            Center(child: Text('Hasta \$${_priceRange.round()}')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5E3C), foregroundColor: Colors.white),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case FilterType.catalog:
        return 'Catálogo';
      case FilterType.inventoryProducts:
        return 'Inventario Productos';
      case FilterType.inventoryIngredients:
        return 'Inventario Ingredientes';
    }
  }
}
