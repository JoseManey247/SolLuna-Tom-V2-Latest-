class SaleRecordModel {
  final int? id;
  final int productoId;
  final int cantidadVendida;
  final int totalVenta;
  final DateTime createdAt;

  SaleRecordModel({
    this.id,
    required this.productoId,
    required this.cantidadVendida,
    required this.totalVenta,
    required this.createdAt,
  });

  factory SaleRecordModel.fromJson(Map<String, dynamic> json) {
    return SaleRecordModel(
      id: json['id'],
      productoId: json['producto_id'],
      cantidadVendida: json['cantidad_vendida'],
      totalVenta: (json['total_venta'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto_id': productoId,
      'cantidad_vendida': cantidadVendida,
      'total_venta': totalVenta,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
