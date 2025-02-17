import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _urlController = TextEditingController();

  Future<void> _saveUrl(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('odoo_url', _urlController.text);
    if (context.mounted) context.pop();
  }

  Future<void> _loadUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString('odoo_url');
    if (url != null) {
      _urlController.text = url;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Odoo API')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Odoo URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => _saveUrl(context), child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
