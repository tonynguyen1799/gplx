import 'package:flutter/material.dart';

class AnimatedShortcutWidget extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badgeText;

  const AnimatedShortcutWidget({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeText,
  });

  static const double subSectionSpacing = 6.0;
  static const double borderRadius = 12.0;

  static const double _padding = 12.0;
  static const Duration _pulseDuration = Duration(milliseconds: 600);
  static const Duration _flipDuration = Duration(milliseconds: 800);
  static const Duration _flipDelay = Duration(seconds: 3);
  static const double _beginScale = 0.8;
  static const double _endScale = 1.2;
  static const double _iconContainerSize = 48.0;
  static const double _transformScale = 1;
  static const double _alphaValue = 0.16;

  @override
  State<AnimatedShortcutWidget> createState() => _AnimatedShortcutWidgetState();
}

class _AnimatedShortcutWidgetState extends State<AnimatedShortcutWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flipController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AnimatedShortcutWidget._pulseDuration,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: AnimatedShortcutWidget._beginScale, end: AnimatedShortcutWidget._endScale).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(begin: widget.color, end: Colors.pinkAccent).animate(_pulseController);

    _flipController = AnimationController(
      vsync: this,
      duration: AnimatedShortcutWidget._flipDuration,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _doFlip();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AnimatedShortcutWidget.borderRadius),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_pulseController, _flipController]),
                  builder: (context, child) {
                    final angle = _flipAnimation.value * 3.1415926535 * 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: Transform.scale(
                        scale: AnimatedShortcutWidget._transformScale * _scaleAnimation.value,
                        child: SizedBox(
                          width: AnimatedShortcutWidget._iconContainerSize,
                          height: AnimatedShortcutWidget._iconContainerSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AnimatedShortcutWidget._padding),
                                decoration: BoxDecoration(
                                  color: (_colorAnimation.value ?? widget.color).withValues(alpha: AnimatedShortcutWidget._alphaValue),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: _colorAnimation.value ?? widget.color,
                                ),
                              ),
                              if (widget.badgeText != null && widget.badgeText!.isNotEmpty)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _colorAnimation.value ?? widget.color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      widget.badgeText!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AnimatedShortcutWidget.subSectionSpacing),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  void _doFlip() async {
    while (mounted) {
      await Future.delayed(AnimatedShortcutWidget._flipDelay);
      if (mounted) {
        _flipController.forward(from: 0);
      }
    }
  }
} 