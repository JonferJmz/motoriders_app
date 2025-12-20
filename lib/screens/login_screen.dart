
import 'package:flutter/material.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleView;
  final VoidCallback loginSuccess;

  const LoginScreen(
      {super.key, required this.toggleView, required this.loginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.login(
      _identifierController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      widget.loginSuccess();
    } else {
      setState(() {
        _errorMessage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          const AnimatedAppLogo(),
          const Spacer(flex: 3),
          const Text("Bienvenido de Vuelta",
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
          const SizedBox(height: 10),
          Text("Inicia sesión para continuar la rodada.",
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),
          TextField(
            controller: _identifierController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Email o Nombre de Usuario"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: "Contraseña",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: _togglePasswordVisibility,
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 30),
          AuthButton(
            text: "Iniciar Sesión",
            onPressed: _loginUser,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: widget.toggleView,
            child: const Text("¿No tienes cuenta? Regístrate",
                style: TextStyle(color: AppColors.teslaRed)),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
