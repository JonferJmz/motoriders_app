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
  // --- CONTROLADORES DE TEXTO ---
  final _fullNameController = TextEditingController(); // NUEVO
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
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

  Future<void> _registerUser() async {
    // Validación básica antes de enviar
    if (_usernameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty) {
      setState(() {
        _errorMessage = "Por favor llena todos los campos.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // --- AQUÍ ESTABA EL ERROR: AHORA ENVIAMOS LOS 4 DATOS ---
    final result = await _authService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _fullNameController.text.trim(), // Enviamos el nombre completo
    );

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      // Si el registro es exitoso, mostramos éxito y vamos al login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Cuenta creada! Inicia sesión.")),
        );
        widget.toggleView(); // Regresa al Login
      }
    } else {
      setState(() {
        _errorMessage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SingleChildScrollView( // Añadido para evitar error de píxeles al sacar teclado
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60), // Espacio superior
            const Text("Únete al Club",
                style: TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
            const SizedBox(height: 10),
            Text("Crea tu perfil y empieza a rodar.",
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 30),
            
            // --- NUEVO CAMPO: NOMBRE COMPLETO ---
            TextField(
              controller: _fullNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Nombre Completo (ej. Jon Fer)"),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}