class Product {
  final int? id;
  final String nombre;
  final int valor;
  final String descripcion;
  final String categoria;
  final String peso;
  final int stock;
  final String imagePath;

  const Product({
    this.id,
    required this.nombre,
    required this.valor,
    required this.descripcion,
    required this.categoria,
    required this.peso,
    this.stock = 0,
    this.imagePath = 'assets/logo_solluna.png',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'] ?? 'Sin nombre',
      valor: (json['precio_venta'] as num?)?.toInt() ?? 0,
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      peso: 'N/A',
      stock: (json['stock_unidades'] as num?)?.toInt() ?? 0,
      imagePath: json['imagen_url'] ?? 'assets/logo_solluna.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'precio_venta': valor,
      'descripcion': descripcion,
      'categoria': categoria,
      'stock_unidades': stock,
      'imagen_url': imagePath,
    };
  }
}
