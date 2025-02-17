import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:odoo_productos/barcode_scanner_screen.dart';
import 'package:odoo_productos/services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'es_PE', symbol: 'S/');

  Future<void> _loadProducts(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final errorNotifier = ScaffoldMessenger.of(context);
    try {
      final products = await ProductService().getProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products';
      });
      errorNotifier
          .showSnackBar(SnackBar(content: Text('Failed to load products')));
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _filterProducts(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = _allProducts.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final barcode = product['barcode']?.toString().toLowerCase() ?? '';
      return name.contains(lowerQuery) || barcode.contains(lowerQuery);
    }).toList();
    setState(() {
      _filteredProducts = filtered;
    });
  }

  Future<void> _scanBarcode(BuildContext context) async {
    final errorNotifier = ScaffoldMessenger.of(context);
    try {
      final scannedBarcode = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );
      if (scannedBarcode != null && scannedBarcode is String) {
        _searchController.text = scannedBarcode;
        _filterProducts(scannedBarcode);
      }
    } catch (e) {
      if (context.mounted) {
        errorNotifier.showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode'),
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterProducts('');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadProducts(context);
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(dynamic price) {
    try {
      double value = 0;
      if (price is num) {
        value = price.toDouble();
      } else if (price is String) {
        value = double.tryParse(price) ?? 0;
      }
      return _currencyFormat.format(value);
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => SystemNavigator.pop(),
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadProducts(context),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterProducts,
                            decoration: InputDecoration(
                              hintText: 'Search by name or barcode',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _clearSearch,
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    onPressed: () => _scanBarcode(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _filteredProducts.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              final price = product['list_price'];
                              return ListTile(
                                title: Text(product['name'] ?? 'No Name'),
                                subtitle: Text('Price: ${_formatPrice(price)}'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
