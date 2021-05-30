import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final List<Color>? colors;
  final ButtonStyle? style;
  final double borderRadius;

  GradientButton({required this.onPressed, this.child, this.colors, this.style, this.borderRadius = 2});

  @override
  Widget build(BuildContext context) {
    Color textColor = this.colors == null ? Colors.black.withOpacity(0.5) : Colors.white;
    return TextButton(
      style: this.style != null
          ? this.style
          : TextButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: textColor,
              textStyle: TextStyle(
                fontFamily: "Roboto",
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
                color: textColor,
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
      onPressed: this.onPressed,
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: this.colors == null
              ? null
              : LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0, 1],
                  colors: this.colors!,
                ),
          color: this.colors != null ? null : Colors.white,
        ),
        child: Container(
          alignment: Alignment.center,
          child: this.child != null ? this.child! : Container(),
        ),
      ),
    );
  }
}
