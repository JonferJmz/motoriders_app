
import 'package:flutter/material.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class AuthScaffold extends StatefulWidget {
  final Widget child;
  const AuthScaffold({super.key, required this.child});

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // FONDO ANIMADO SUTIL
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF100a1c),
                      Colors.black.withOpacity(0.8 + (_controller.value * 0.2)),
                    ],
                  ),
                ),
              );
            },
          ),
          // IMAGEN DE FONDO MÁS VISIBLE
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?q=80&w=2070&auto=format&fit=crop'),
                fit: BoxFit.cover,
                opacity: 0.25, // <-- AUMENTAMOS LA OPACIDAD
              ),
            ),
          ),
          // DEGRADADO PARA LEGIBILIDAD
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.8)],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedAppLogo extends StatefulWidget {
  const AnimatedAppLogo({super.key});

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimationMoto;
  late Animation<Offset> _slideAnimationMoto;
  late Animation<double> _fadeAnimationRiders;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimationMoto = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _fadeAnimationMoto = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    _fadeAnimationRiders = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
          fontFamily: 'Inter',
        ),
        children: [
          WidgetSpan(
            child: FadeTransition(
              opacity: _fadeAnimationMoto,
              child: SlideTransition(
                position: _slideAnimationMoto,
                child: const Text("MOTO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, fontFamily: 'Inter')),
              ),
            ),
          ),
          WidgetSpan(
            child: FadeTransition(
              opacity: _fadeAnimationRiders,
              child: Text("RIDERS", style: TextStyle(color: AppColors.teslaRed.withOpacity(0.9), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, fontFamily: 'Inter')),
            ),
          ),
        ],
      ),
    );
  }
}
