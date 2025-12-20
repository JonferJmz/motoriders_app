import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para vibración
import 'package:motoriders_app/models/reaction_model.dart';

class ReactionItem {
  final ReactionType id;
  final String label;
  final IconData icon;
  final Color color;

  const ReactionItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class AnimatedReactionButton extends StatefulWidget {
  final Function(ReactionType) onReactionSelected;
  final VoidCallback? onReactionRemoved;
  final ReactionType? initialReaction;

  const AnimatedReactionButton({
    Key? key,
    required this.onReactionSelected,
    this.onReactionRemoved,
    this.initialReaction,
  }) : super(key: key);

  @override
  _AnimatedReactionButtonState createState() => _AnimatedReactionButtonState();
}

class _AnimatedReactionButtonState extends State<AnimatedReactionButton> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Controlamos el índice seleccionado
  final ValueNotifier<int?> _hoveredIndexNotifier = ValueNotifier<int?>(null);

  // Dimensiones corregidas para que NO se salga de la pantalla
  final double _itemWidth = 45.0; // Ancho de zona de cada icono
  final double _containerHeight = 70.0;

  final List<ReactionItem> _reactions = [
    ReactionItem(id: ReactionType.like, label: 'Like', icon: Icons.thumb_up, color: Colors.blue),
    ReactionItem(id: ReactionType.love, label: 'Love', icon: Icons.favorite, color: Colors.red),
    ReactionItem(id: ReactionType.gas, label: 'GAS!', icon: Icons.flash_on, color: Colors.amber),
    ReactionItem(id: ReactionType.haha, label: 'Jaja', icon: Icons.sentiment_very_satisfied, color: Colors.yellow),
    ReactionItem(id: ReactionType.angry, label: 'Enoja', icon: Icons.local_fire_department, color: Colors.deepOrange),
  ];

  void _showOverlay() {
    if (_overlayEntry != null) return;
    HapticFeedback.selectionClick();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hoveredIndexNotifier.value = null;
  }

  // --- LÓGICA MATEMÁTICA CORREGIDA ---
  // Ahora detectamos el dedo basándonos en una tira horizontal que empieza en el botón
  void _updateHover(Offset globalPosition) {
    if (_overlayEntry == null) return;

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset buttonPosition = renderBox.localToGlobal(Offset.zero);

    // El menú empieza EXACTAMENTE donde empieza el botón (alineado a la izquierda)
    // Ajustamos -10 píxeles para dar un margen de error cómodo
    double startMenuX = buttonPosition.dx - 10;

    // Posición Y base del menú
    double menuY = buttonPosition.dy - _containerHeight;

    // Calculamos dónde está el dedo relativo al inicio del menú
    double localX = globalPosition.dx - startMenuX;
    double localY = globalPosition.dy - menuY;

    // Zona segura vertical: Si subes o bajas mucho el dedo, se cancela
    if (localY < -50 || localY > 150) {
      _hoveredIndexNotifier.value = null;
      return;
    }

    // Calculamos índice basado en el ancho de cada item
    // Ya no usamos ángulos, usamos posición lineal (más preciso y ordenado)
    int index = (localX / _itemWidth).floor();

    // Limites
    if (index < 0) index = -1; // Fuera por la izquierda
    if (index >= _reactions.length) index = -1; // Fuera por la derecha

    if (index >= 0) {
      if (_hoveredIndexNotifier.value != index) {
        HapticFeedback.selectionClick(); // Tic mecánico
        _hoveredIndexNotifier.value = index;
      }
    } else {
      _hoveredIndexNotifier.value = null;
    }
  }

  void _handleSelection(ReactionType selectedType) {
    HapticFeedback.heavyImpact(); // Vibración sólida al confirmar
    if (widget.initialReaction == selectedType) {
      widget.onReactionRemoved?.call();
    } else {
      widget.onReactionSelected(selectedType);
    }
  }

  OverlayEntry _createOverlayEntry() {
    // Calculamos el ancho total del contenedor negro
    double totalWidth = _reactions.length * _itemWidth;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: totalWidth + 20, // Un poco de espacio extra
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            // CORRECCIÓN CRÍTICA:
            // Offset(0, ...) significa "Alineado a la izquierda del botón".
            // -75 lo sube justo encima del botón.
            // YA NO SE SALDRÁ DE LA PANTALLA POR LA IZQUIERDA.
            offset: const Offset(0, -75),
            child: Material(
              color: Colors.transparent,
              child: ValueListenableBuilder<int?>(
                valueListenable: _hoveredIndexNotifier,
                builder: (context, hoveredIndex, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. EL FONDO (HUD / TABLERO)
                      // Una pastilla negra semitransparente, limpia, sin brillos locos
                      Container(
                        height: 55,
                        width: totalWidth,
                        decoration: BoxDecoration(
                          color: const Color(0xFF202020), // Gris muy oscuro (Casi negro)
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white12, width: 1), // Borde sutil
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                      ),

                      // 2. LOS ICONOS
                      Row(
                        children: List.generate(_reactions.length, (index) {
                          bool isHovered = hoveredIndex == index;
                          return _buildIconItem(index, isHovered);
                        }),
                      ),

                      // 3. ETIQUETA FLOTANTE (SOLO SI HAY SELECCIÓN)
                      if (hoveredIndex != null)
                        Positioned(
                          top: -35, // Flota arriba del tablero
                          left: (hoveredIndex * _itemWidth) + (_itemWidth / 2) - 40, // Centrado sobre el icono
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _reactions[hoveredIndex].color, // Color sólido del tipo de reacción
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _reactions[hoveredIndex].label.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black, // Texto negro sobre fondo de color para contraste
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconItem(int index, bool isHovered) {
    return Container(
      width: _itemWidth,
      height: 55,
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutQuad,
        // Al seleccionar: Crece y sube un poco
        transform: Matrix4.identity()
          ..scale(isHovered ? 1.3 : 1.0)
          ..translate(0.0, isHovered ? -5.0 : 0.0),
        child: Icon(
          _reactions[index].icon,
          // LÓGICA DE COLOR LIMPIA:
          // Si está seleccionado -> Usa su color original (Rojo, Azul, Ambar)
          // Si NO está seleccionado -> Gris claro (para no distraer)
          color: isHovered ? _reactions[index].color : Colors.grey[500],
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.grey;
    IconData buttonIcon = Icons.thumb_up_alt_outlined;
    String buttonText = "Gas";

    if (widget.initialReaction != null) {
      try {
        final activeItem = _reactions.firstWhere((r) => r.id == widget.initialReaction);
        buttonColor = activeItem.color;
        buttonIcon = activeItem.icon;
        buttonText = activeItem.label;
      } catch (e) {
        buttonColor = Colors.blue;
        buttonIcon = Icons.thumb_up;
      }
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,

        onLongPressStart: (details) {
          _showOverlay();
          _updateHover(details.globalPosition);
        },
        onLongPressMoveUpdate: (details) {
          _updateHover(details.globalPosition);
        },
        onLongPressEnd: (details) {
          if (_hoveredIndexNotifier.value != null) {
            final selected = _reactions[_hoveredIndexNotifier.value!];
            _handleSelection(selected.id);
          }
          _hideOverlay();
        },
        onLongPressCancel: () => _hideOverlay(),

        onTap: () {
          _handleSelection(ReactionType.gas);
        },

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pequeña animación de escala al presionar
              AnimatedScale(
                scale: widget.initialReaction != null ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(buttonIcon, color: buttonColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                buttonText,
                style: TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}