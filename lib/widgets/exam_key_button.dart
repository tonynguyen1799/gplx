import 'package:flutter/material.dart';

class ExamKeyButton extends StatefulWidget {
  final String notPressedAssetPath;
  final String pressedAssetPath;
  final double size;
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? semanticLabel;
  final Widget? overlayChild; // e.g., an Icon or Text like a left arrow
  final Alignment overlayAlignment; // position of overlay on the keycap
  final double bleedScale; // slightly scale image to overlap neighbors and remove seams
  final double bleedPx; // extend image beyond bounds horizontally to cover seams

  const ExamKeyButton({
    super.key,
    required this.notPressedAssetPath,
    required this.pressedAssetPath,
    this.size = 60,
    this.onTap,
    this.isEnabled = true,
    this.semanticLabel,
    this.overlayChild,
    this.overlayAlignment = Alignment.center,
    this.bleedScale = 1.0,
    this.bleedPx = 1.0,
  });

  @override
  State<ExamKeyButton> createState() => _ExamKeyButtonState();
}

class _ExamKeyButtonState extends State<ExamKeyButton> {
  static const int _animationMs = 60; // fast switch
  static const int _holdAfterTapUpMs = 70; // brief hold for visibility

  bool _pressed = false;
  bool _releasing = false; // guard to avoid duplicate release handling

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache both images so the first press has no decode delay
    precacheImage(AssetImage(widget.notPressedAssetPath), context);
    precacheImage(AssetImage(widget.pressedAssetPath), context);
  }

  void _setPressed(bool value) {
    if (!widget.isEnabled) return;
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  Future<void> _handleRelease({required bool triggerTap}) async {
    if (!mounted || !widget.isEnabled) return;
    if (_releasing) return; // prevent double invocations (e.g., panEnd + tapUp)
    _releasing = true;
    try {
      if (triggerTap) {
        widget.onTap?.call();
      }
      // Keep pressed state visible briefly so users notice the change
      await Future.delayed(const Duration(milliseconds: _holdAfterTapUpMs));
      if (mounted) _setPressed(false);
    } finally {
      _releasing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Duration: instant when going into pressed, short animate when releasing
    final Duration duration = _pressed
        ? Duration.zero
        : Duration(milliseconds: _animationMs);

    Widget buildLayer(String asset) {
      final double scaledWidth = widget.size * widget.bleedScale;
      final double scaledHeight = widget.size * widget.bleedScale;
      final double overflowWidth = scaledWidth + widget.bleedPx * 2;
      return OverflowBox(
        minWidth: overflowWidth,
        maxWidth: overflowWidth,
        minHeight: scaledHeight,
        maxHeight: scaledHeight,
        alignment: Alignment.center,
        child: Image.asset(
          asset,
          width: overflowWidth,
          height: scaledHeight,
          fit: BoxFit.cover,
          semanticLabel: widget.semanticLabel,
          filterQuality: FilterQuality.high,
        ),
      );
    }

    final content = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Unpressed image layer
          AnimatedOpacity(
            opacity: !_pressed ? 1.0 : 0.0,
            duration: duration,
            curve: Curves.easeOut,
            child: buildLayer(widget.notPressedAssetPath),
          ),
          // Pressed image layer
          AnimatedOpacity(
            opacity: _pressed ? 1.0 : 0.0,
            duration: duration,
            curve: Curves.easeIn,
            child: buildLayer(widget.pressedAssetPath),
          ),
          if (widget.overlayChild != null)
            Align(
              alignment: widget.overlayAlignment,
              child: widget.overlayChild!,
            ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onPanDown: (_) => _setPressed(true),
      onLongPressStart: (_) => _setPressed(true),
      onPanEnd: (_) => _handleRelease(triggerTap: false),
      onLongPressEnd: (_) => _handleRelease(triggerTap: true),
      onTapUp: (_) => _handleRelease(triggerTap: true),
      onTapCancel: () => _setPressed(false),
      child: IgnorePointer(
        ignoring: !widget.isEnabled,
        child: Opacity(
          opacity: widget.isEnabled ? 1.0 : 0.4,
          child: content,
        ),
      ),
    );
  }
} 