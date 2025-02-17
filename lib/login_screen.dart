import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odoo_productos/services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _databaseController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final loginService = LoginService();
    bool success = await loginService.login(
      _usernameController.text,
      _passwordController.text,
      _databaseController.text,
    );
    if (success) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('odoo_username', _usernameController.text);
      await prefs.setString('odoo_password', _passwordController.text);
      await prefs.setString('odoo_database', _databaseController.text);
      if (context.mounted) context.go('/');
    } else {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _usernameController.text = prefs.getString('odoo_username') ?? '';
    _passwordController.text = prefs.getString('odoo_password') ?? '';
    _databaseController.text = prefs.getString('odoo_database') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _databaseController,
                    decoration: const InputDecoration(
                      labelText: 'Database',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _login(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            context.push('/config');
                          },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Configure Odoo API'),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
