class Recipe {
  final int? id;
  final int? productoId;
  final String nombre;
  final double pesoBase;
  final String instrucciones;
  final List<RecipeIngredient> ingredients;

  Recipe({
    this.id,
    this.productoId,
    required this.nombre,
    required this.pesoBase,
    required this.instrucciones,
    this.ingredients = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    var list = json['formula_detalle'] as List? ?? [];
    List<RecipeIngredient> ingredientList = list.map((i) => RecipeIngredient.fromJson(i)).toList();

    return Recipe(
      id: json['id'],
      productoId: json['producto_id'],
      nombre: json['nombre_formula'] ?? '',
      pesoBase: (json['peso_base_g'] ?? 100.0).toDouble(),
      instrucciones: json['instrucciones'] ?? '',
      ingredients: ingredientList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto_id': productoId,
      'nombre_formula': nombre,
      'peso_base_g': pesoBase,
      'instrucciones': instrucciones,
    };
  }
}

class RecipeIngredient {
  final int? id;
  final int insumoId;
  final String? nombreInsumo;
  final String fase;
  final String funcion; // Nuevo campo
  final double porcentaje;
  final double gramos;

  RecipeIngredient({
    this.id,
    required this.insumoId,
    this.nombreInsumo,
    required this.fase,
    this.funcion = '', // Valor por defecto
    required this.porcentaje,
    required this.gramos,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      insumoId: json['insumo_id'],
      nombreInsumo: json['insumos']?['nombre'],
      fase: json['fase'] ?? '',
      funcion: json['funcion'] ?? '', // Lee de la base de datos
      porcentaje: (json['porcentaje'] ?? 0.0).toDouble(),
      gramos: (json['gramos_base'] ?? 0.0).toDouble(),
    );
  }
}
