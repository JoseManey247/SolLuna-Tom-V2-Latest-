import 'package:flutter/material.dart';

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
    final String nombre = (json['Nombre'] ?? json['nombre'] ?? 'Sin nombre').toString().trim();
    
    // Función simplificada para coincidir exactamente con tu nuevo plan
    String cleanFilename(String text) {
      String result = text.trim();
      
      // Única regla: Quitar acentos para evitar errores de URL
      const map = {
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
        'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U',
        'ñ': 'n', 'Ñ': 'N'
      };
      map.forEach((key, value) => result = result.replaceAll(key, value));

      return result;
    }

    // Si no hay URL o está vacía, creamos el nombre del archivo limpio
    String dbPath = json['imagen_url']?.toString().trim() ?? '';
    String generatedPath;
    
    if (dbPath.isEmpty) {
      // REGLA ESPECIAL: Si empieza con Agua de Florida, usar la misma imagen para todos
      if (nombre.toLowerCase().startsWith('agua de florida')) {
        generatedPath = 'Agua de Florida.png';
      } else {
        generatedPath = '${cleanFilename(nombre)}.png';
      }
    } else {
      generatedPath = dbPath;
      // Asegurarnos de que tenga extensión
      if (!generatedPath.toLowerCase().endsWith('.png') && !generatedPath.toLowerCase().endsWith('.jpg')) {
        generatedPath += '.png';
      }
    }

    return Product(
      id: json['id'],
      nombre: nombre,
      valor: (json['precio_venta'] as num?)?.toInt() ?? 0,
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      peso: 'N/A',
      stock: (json['stock_unidades'] as num?)?.toInt() ?? 0,
      imagePath: generatedPath,
    );
  }

  // Helper para decidir cómo mostrar la imagen
  Widget buildImage({double? width, double? height, BoxFit fit = BoxFit.contain}) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/logo_solluna.png', width: width, height: height, fit: fit),
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      // Usamos Uri.encodeComponent para manejar espacios y mayúsculas de forma segura
      final String encodedPath = Uri.encodeComponent(imagePath);
      final String fullUrl = 'https://ppzdlawsjphuoewicyqq.supabase.co/storage/v1/object/public/images_solluna_products/$encodedPath';
      
      debugPrint('Buscando imagen literal: $fullUrl');

      return Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/logo_solluna.png', width: width, height: height, fit: fit);
        },
      );
    }
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
