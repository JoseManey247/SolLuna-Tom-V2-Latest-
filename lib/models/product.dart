class Product {
  final int? id;
  final String nombre;
  final int valor;
  final String descripcion;
  final String categoria;
  final String peso;
  final int stock;
  final String imagePath;

  Product({
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
      nombre: json['nombre'],
      valor: json['precio_venta'],
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      peso: 'N/A', // Not in DB schema shared, using default
      stock: json['stock_unidades'] ?? 0,
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

// Keeping mockProducts for now to avoid breaking UI until fully connected
final List<Product> mockProducts = [
  Product(
    id: 1,
    nombre: 'Aceite de Cannabis',
    valor: 12000,
    categoria: 'Aceites',
    peso: '30 ml',
    stock: 15,
    descripcion: 'Analgésico antiinflamatorio, calmante del sistema nervioso central, hierba macerada en aceite de oliva. 3 gotas sublingual 2 veces al día.',
  ),
  Product(
    id: 2,
    nombre: 'Aceite de Orégano',
    valor: 15000,
    categoria: 'Aceites',
    peso: '30 ml',
    stock: 8,
    descripcion: 'Desparasitante, antibacteriano, poderoso fungicida, elimina hongo cándida, aumenta las defensas. 3 gotas en ayuno por 7 días y descansar 7.',
  ),
  Product(
    id: 3,
    nombre: 'Aceite de Ricino',
    valor: 6000,
    categoria: 'Aceites',
    peso: '30 ml',
    stock: 20,
    descripcion: 'Antiinflamatorio, se usa en medicina ayurveda para masajes de útero y espalda.',
  ),
  Product(
    id: 4,
    nombre: 'Agua de Florida Lavanda',
    valor: 7000,
    categoria: 'Aguas Alquímicas',
    peso: '100 ml',
    stock: 12,
    descripcion: 'Agua de limpieza energética y aromatizante de ambientes especial para calmar y bajar ansiedad. Uso: en los ambientes, cortina, almohadas.',
  ),
  Product(
    id: 5,
    nombre: 'Crema Urea 20%',
    valor: 18000,
    categoria: 'Cremas',
    peso: '200 g',
    stock: 10,
    descripcion: 'Reparadora de piel seca y extra seca. Especial para pies, codos y brazos con queratosis.',
  ),
  Product(
    id: 6,
    nombre: 'Jabón Carbón Activado',
    valor: 3500,
    categoria: 'Jabones',
    peso: '100 g',
    stock: 25,
    descripcion: 'Purificante, elimina toxinas y células muertas de la piel, permite exfoliación y regeneración.',
  ),
  Product(
    id: 7,
    nombre: 'Aromaterapia Calmante',
    valor: 10000,
    categoria: 'Aromaterapia',
    peso: '10 ml',
    stock: 14,
    descripcion: 'Mezcla de aceites esenciales que permiten bajar los niveles de estrés y ansiedad. Aceite conductor es de Almendras. No exponer al calor.',
  ),
  Product(
    id: 8,
    nombre: 'Bálsamo Labial Almendras',
    valor: 3000,
    categoria: 'Bálsamos',
    peso: '10 g',
    stock: 30,
    descripcion: 'Mantecas hidratantes y protectoras para labios.',
  ),
];
