
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final List<Color>? colors;

  GradientButton({required this.onPressed, this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      onPressed: this.onPressed,
      child: Ink(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
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
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w500,
              fontSize: 18.0,
              color: this.colors == null ? Colors.black.withOpacity(0.5) : Colors.white,
            ),
            child: this.child != null ? this.child! : Container(),
          ),
        ),
      ),
    );
  }
}