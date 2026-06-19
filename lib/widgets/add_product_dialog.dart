import 'package:flutter/material.dart';
import '../models/product.dart';

class AddProductDialog extends StatefulWidget {
  final List<Product> existingProducts;
  final Function(Product, int) onUpdateStock;
  final Function(Product) onAddNew;

  const AddProductDialog({
    super.key,
    required this.existingProducts,
    required this.onUpdateStock,
    required this.onAddNew,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  bool _isNewProduct = false;
  Product? _selectedProduct;
  int _quantityToAdd = 1;

  // Controllers for new product
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFEFE6D5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Agregar producto',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5E3C).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildModeButton('Ya registrado', active: !_isNewProduct, onTap: () => setState(() => _isNewProduct = false)),
                  const SizedBox(width: 12),
                  _buildModeButton('Nuevo producto', active: _isNewProduct, onTap: () => setState(() => _isNewProduct = true)),
                ],
              ),
              const SizedBox(height: 24),
              if (!_isNewProduct) _buildExistingMode() else _buildNewMode(),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton('Atras', isSecondary: true, onTap: () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      _isNewProduct ? 'Agregar Producto' : 'Actualizar Stock',
                      onTap: _handleSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, {required bool active, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF5D5D5D) : const Color(0xFFC4A484).withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildExistingMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Elegir producto', style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFC4A484).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Product>(
              value: _selectedProduct,
              isExpanded: true,
              dropdownColor: const Color(0xFFEFE6D5),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8B5E3C)),
              hint: const Text('Seleccionar...', style: TextStyle(color: Colors.white)),
              items: widget.existingProducts.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.nombre, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedProduct = val),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Cantidad a agregar', style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCounterButton(Icons.keyboard_arrow_down, () {
              if (_quantityToAdd > 1) setState(() => _quantityToAdd--);
            }),
            Expanded(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC4A484).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$_quantityToAdd',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            _buildCounterButton(Icons.keyboard_arrow_up, () => setState(() => _quantityToAdd++)),
          ],
        ),
      ],
    );
  }

  Widget _buildNewMode() {
    return Column(
      children: [
        _buildTextField(_nombreController, 'Nombre'),
        _buildTextField(_categoriaController, 'Categoría'),
        _buildTextField(_precioController, 'Precio de Venta', isNumber: true),
        _buildTextField(_stockController, 'Stock Inicial', isNumber: true),
        _buildTextField(_descripcionController, 'Descripción (Opcional)', maxLines: 2),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          labelStyle: const TextStyle(color: Color(0xFF8B5E3C)),
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFC4A484).withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildActionButton(String label, {bool isSecondary = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSecondary ? const Color(0xFFC4A484) : const Color(0xFFC4A484),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_isNewProduct) {
      if (_nombreController.text.isEmpty || _precioController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa los campos obligatorios')));
        return;
      }
      final newProduct = Product(
        nombre: _nombreController.text,
        categoria: _categoriaController.text,
        valor: int.tryParse(_precioController.text) ?? 0,
        stock: int.tryParse(_stockController.text) ?? 0,
        descripcion: _descripcionController.text,
        peso: 'N/A',
      );
      widget.onAddNew(newProduct);
    } else {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona un producto')));
        return;
      }
      widget.onUpdateStock(_selectedProduct!, _quantityToAdd);
    }
    Navigator.pop(context);
  }
}
