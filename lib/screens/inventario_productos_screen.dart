import 'package:flutter/material.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/add_product_dialog.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class InventarioProductosScreen extends StatefulWidget {
  const InventarioProductosScreen({super.key});

  @override
  State<InventarioProductosScreen> createState() => _InventarioProductosScreenState();
}

class _InventarioProductosScreenState extends State<InventarioProductosScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  FilterOptions? _currentFilters;
  late Stream<List<Product>> _productsStream;
  List<Product> _lastProducts = [];

  @override
  void initState() {
    super.initState();
    _updateStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateStream() {
    setState(() {
      _productsStream = _productService.getProductsStream(
        options: _currentFilters,
        search: _searchController.text,
      );
    });
  }

  void _showFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        type: FilterType.inventoryProducts,
        onApply: (options) {
          setState(() {
            _currentFilters = options;
            _updateStream();
          });
        },
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        existingProducts: _lastProducts,
        onUpdateStock: (product, quantity) async {
          try {
            await _productService.updateStock(product.id!, product.stock + quantity);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock actualizado con éxito'), backgroundColor: Colors.green),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actualizar stock: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
        onAddNew: (newProduct) async {
          try {
            await _productService.addProduct(newProduct);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nuevo producto agregado'), backgroundColor: Colors.green),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al agregar producto: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.nombre}"? Esta acción no se puede deshacer.'),
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

    if (confirm == true && product.id != null) {
      try {
        await _productService.deleteProduct(product.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado con éxito'), backgroundColor: Colors.green),
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

  Future<void> _showEditDialog(Product product) async {
    final nombreController = TextEditingController(text: product.nombre);
    final categoriaController = TextEditingController(text: product.categoria);
    final stockController = TextEditingController(text: product.stock.toString());
    final precioController = TextEditingController(text: product.valor.toString());
    final descripcionController = TextEditingController(text: product.descripcion);
    final imagenController = TextEditingController(text: product.imagePath);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: categoriaController, decoration: const InputDecoration(labelText: 'Categoría')),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
              TextField(controller: precioController, decoration: const InputDecoration(labelText: 'Precio de Venta'), keyboardType: TextInputType.number),
              TextField(controller: imagenController, decoration: const InputDecoration(labelText: 'Nombre del archivo de imagen (ej: aceite.png)')),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final updatedProduct = Product(
                id: product.id,
                nombre: nombreController.text,
                categoria: categoriaController.text,
                stock: int.tryParse(stockController.text) ?? product.stock,
                valor: int.tryParse(precioController.text) ?? product.valor,
                descripcion: descripcionController.text,
                imagePath: imagenController.text,
                peso: product.peso,
              );
              
              try {
                await _productService.updateProduct(updatedProduct);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto actualizado'), backgroundColor: Colors.green),
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
            'Inventario Productos',
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
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add_circle_outline, size: 18),
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
            child: StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _lastProducts.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5E3C)));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error al cargar productos: ${snapshot.error}'),
                      ],
                    ),
                  );
                } 

                if (snapshot.hasData) {
                  _lastProducts = snapshot.data!;
                }

                if (_lastProducts.isEmpty) {
                  return const Center(child: Text('No hay productos en el inventario.'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Color(0xFF8B5E3C)),
                          const SizedBox(width: 8),
                          Text(
                            'Total de productos registrados: ${_lastProducts.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5E3C)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _lastProducts.length,
                        itemBuilder: (context, index) {
                          final product = _lastProducts[index];
                          return _buildInventoryItem(product);
                        },
                      ),
                    ),
                  ],
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
        border: Border.all(color: const Color(0xFFD2B48C).withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8B5E3C)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _updateStream(),
              decoration: const InputDecoration(
                hintText: 'Buscar en el inventario...',
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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
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

  Widget _buildInventoryItem(Product product) {
    final alert = product.stock <= 5 ? (product.stock == 0 ? '¡Sin Stock!' : 'Por agotar') : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Color(0xFF8B5E3C), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(product.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4E342E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(onPressed: () => _showEditDialog(product), icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20)),
                IconButton(onPressed: () => _confirmDelete(product), icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
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
                    Text(product.categoria, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Actual', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    Text('${product.stock} U', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8B5E3C))),
                  ],
                ),
                if (alert != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.contains('Sin') ? Colors.red[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: alert.contains('Sin') ? Colors.red[200]! : Colors.orange[200]!),
                    ),
                    child: Text(
                      alert,
                      style: TextStyle(color: alert.contains('Sin') ? Colors.red[900] : Colors.orange[900], fontSize: 10, fontWeight: FontWeight.bold),
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
