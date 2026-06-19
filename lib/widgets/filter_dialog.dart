import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FilterType { catalog, inventoryProducts, inventoryIngredients, recipe }

class FilterOptions {
  final List<String> selectedFields;
  final String orderType; // 'az', 'za', 'high', 'low', 'id_desc'
  final RangeValues? priceRange;
  final DateTime? startDate;
  final DateTime? endDate;

  FilterOptions({
    required this.selectedFields,
    required this.orderType,
    this.priceRange,
    this.startDate,
    this.endDate,
  });
}

class FilterDialog extends StatefulWidget {
  final FilterType type;
  final Function(FilterOptions)? onApply;

  const FilterDialog({super.key, required this.type, this.onApply});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final Map<String, bool> _fields = {};
  String _orderDirection = 'az'; // Default
  RangeValues _priceRange = const RangeValues(0, 100000);
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    if (widget.type == FilterType.catalog) {
      _fields['Nombre producto'] = false;
      _fields['Categoria producto'] = false;
      _fields['Alerta de estado'] = false;
      _fields['Stock producto'] = false;
    } else if (widget.type == FilterType.inventoryIngredients) {
      _fields['Nombre ingrediente'] = false;
      _fields['Categoria ingrediente'] = false;
      _fields['Alerta de estado'] = false;
      _fields['Stock producto'] = false; // Keeping user mockup text
    } else if (widget.type == FilterType.inventoryProducts) {
      _fields['Nombre producto'] = false;
      _fields['Categoria producto'] = false;
      _fields['Alerta de estado'] = false;
      _fields['Stock producto'] = false;
    } else {
      _fields['Nombre'] = false;
      _fields['Categoría'] = false;
    }
  }

  bool _isTextOnlySelected() {
    int count = 0;
    bool onlyText = true;
    _fields.forEach((key, value) {
      if (value) {
        count++;
        if (key.contains('Precio') || key.contains('Stock') || key.contains('Alerta')) {
          onlyText = false;
        }
      }
    });
    return count > 0 && onlyText;
  }

  bool _isNumericOnlySelected() {
    int count = 0;
    bool onlyNumeric = true;
    _fields.forEach((key, value) {
      if (value) {
        count++;
        if (key.contains('Nombre') || key.contains('Categoria')) {
          onlyNumeric = false;
        }
      }
    });
    return count > 0 && onlyNumeric;
  }

  int _getSelectedCount() {
    return _fields.values.where((v) => v).length;
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5E3C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF5D4037),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool multipleSelected = _getSelectedCount() > 1;
    bool textSelected = _isTextOnlySelected();
    bool numericSelected = _isNumericOnlySelected();

    return AlertDialog(
      backgroundColor: const Color(0xFFEFE6D5), // Matches mockup background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: Color(0xFF8B5E3C), size: 30),
                const SizedBox(width: 10),
                Text(
                  'Filtrar por ...',
                  style: TextStyle(fontSize: 22, color: const Color(0xFF8B5E3C).withOpacity(0.8), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._fields.keys.map((key) => Theme(
              data: ThemeData(unselectedWidgetColor: const Color(0xFF8B5E3C)),
              child: CheckboxListTile(
                title: Text(key, style: const TextStyle(color: Color(0xFF8B5E3C), fontSize: 18)),
                value: _fields[key],
                activeColor: const Color(0xFF8B5E3C),
                onChanged: (val) => setState(() => _fields[key] = val!),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            )),
            const SizedBox(height: 20),
            const Text('Ordenar por:', style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildSortButton('A -Z / Z - A', active: !multipleSelected && textSelected, value1: 'az', value2: 'za'),
                const SizedBox(width: 12),
                _buildSortButton('Mayor / Menor', active: !multipleSelected && numericSelected, value1: 'high', value2: 'low'),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.type == FilterType.catalog) ...[
              const Text('Rango de precio', style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18)),
              const SizedBox(height: 8),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100000,
                activeColor: const Color(0xFF8B5E3C),
                inactiveColor: const Color(0xFFD2B48C).withOpacity(0.5),
                onChanged: (val) => setState(() => _priceRange = val),
              ),
              Center(child: Text('\$${_priceRange.start.round()} - \$${_priceRange.end.round()}', style: const TextStyle(color: Color(0xFF8B5E3C)))),
            ] else if (widget.type != FilterType.recipe) ...[
              const Text('Rango de fecha', style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDateButton(_startDate != null ? DateFormat('dd/MM/yy').format(_startDate!) : 'Desde', () => _pickDate(true)),
                  const SizedBox(width: 12),
                  _buildDateButton(_endDate != null ? DateFormat('dd/MM/yy').format(_endDate!) : 'Hasta', () => _pickDate(false)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  String finalOrder = multipleSelected ? 'id_desc' : _orderDirection;
                  widget.onApply?.call(FilterOptions(
                    selectedFields: _fields.entries.where((e) => e.value).map((e) => e.key).toList(),
                    orderType: finalOrder,
                    priceRange: widget.type == FilterType.catalog ? _priceRange : null,
                    startDate: _startDate,
                    endDate: _endDate,
                  ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD2B48C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Filtrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(String label, {required bool active, required String value1, required String value2}) {
    bool isValue1 = _orderDirection == value1;
    bool isValue2 = _orderDirection == value2;
    bool isCurrentGroup = isValue1 || isValue2;

    // Determine specific label and arrow based on current state
    String displayLabel = label;
    if (active && isCurrentGroup) {
      if (label.contains('A -Z')) {
        displayLabel = isValue1 ? 'A → Z' : 'Z → A';
      } else {
        displayLabel = isValue1 ? 'Mayor → Menor' : 'Menor → Mayor';
      }
    }

    return Expanded(
      child: InkWell(
        onTap: active
            ? () {
                setState(() {
                  // If clicking the same group, toggle between value1 and value2
                  if (_orderDirection == value1) {
                    _orderDirection = value2;
                  } else {
                    _orderDirection = value1;
                  }
                });
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active && isCurrentGroup ? const Color(0xFF8B5E3C) : const Color(0xFFC4A484).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active && isCurrentGroup ? const Color(0xFF8B5E3C) : const Color(0xFF8B5E3C).withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayLabel,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF8B5E3C).withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (active && isCurrentGroup) ...[
                  const SizedBox(width: 4),
                  Icon(
                    label.contains('A -Z') 
                      ? (isValue1 ? Icons.arrow_downward : Icons.arrow_upward)
                      : (isValue1 ? Icons.arrow_downward : Icons.arrow_upward),
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFC4A484).withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
