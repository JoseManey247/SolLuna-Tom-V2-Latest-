import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/ventas_screen.dart';
import 'screens/inventario_productos_screen.dart';
import 'screens/inventario_ingredientes_screen.dart';
import 'screens/recetario_screen.dart';
import 'screens/catalogo_screen.dart';
import 'widgets/custom_sidebar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolLuna Tomé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5E3C),
          primary: const Color(0xFF8B5E3C),
          secondary: const Color(0xFFD2B48C),
          surface: const Color(0xFFFDF5E6),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF5E6),
        useMaterial3: true,
        // Using serif for a more natural, herbalist feel
        //fontFamily: 'Georgia',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Color(0xFF5D4037), letterSpacing: -0.5),
          displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF5D4037)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
        ),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: (index) {
        setState(() {
          _selectedIndex = index;
        });
      }),
      const CatalogoScreen(),
      const RecetarioScreen(),
      const VentasScreen(),
      const InventarioProductosScreen(),
      const InventarioIngredientesScreen(),
      const Center(child: Text('Configuración Placeholder')), // Configuración
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF8B5E3C), size: 32),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF8B5E3C), size: 32),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/logo_solluna.png',
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.spa, color: Color(0xFF8B5E3C), size: 40),
            ),
          ),
        ],
      ),
      drawer: CustomSidebar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: _screens[_selectedIndex],
    );
  }
}
