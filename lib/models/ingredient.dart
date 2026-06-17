class Ingredient {
  final int? id;
  final String nombre;
  final String categoria;
  final double cantidadRestante;
  final String unidadMedida;
  final double alertaStockBajo;

  Ingredient({
    this.id,
    required this.nombre,
    required this.categoria,
    required this.cantidadRestante,
    required this.unidadMedida,
    required this.alertaStockBajo,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'] ?? '',
      cantidadRestante: (json['cantidad_restante'] ?? 0).toDouble(),
      unidadMedida: json['unidad_medida'] ?? 'U',
      alertaStockBajo: (json['alerta_stock_bajo'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'cantidad_restante': cantidadRestante,
      'unidad_medida': unidadMedida,
      'alerta_stock_bajo': alertaStockBajo,
    };
  }
}
