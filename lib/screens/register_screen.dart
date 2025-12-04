
import 'package:flutter/material.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleView;

  const RegisterScreen({super.key, required this.toggleView});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Las contraseñas no coinciden.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result == "Success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Registro exitoso! Ahora inicia sesión."),
          backgroundColor: Colors.green,
        ),
      );
      widget.toggleView(); // Cambia a la pantalla de Login
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
          const Text("Únete a la Rodada",
              style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
          const SizedBox(height: 10),
          Text("Crea tu cuenta en segundos.",
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Nombre de Usuario"),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Correo Electrónico"),
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
          const SizedBox(height: 20),
          TextField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: Colors.white),
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: "Confirmar Contraseña",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: _toggleConfirmPasswordVisibility,
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
            text: "Registrarse",
            onPressed: _registerUser,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: widget.toggleView,
            child: const Text("¿Ya tienes cuenta? Inicia Sesión",
                style: TextStyle(color: AppColors.teslaRed)),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
