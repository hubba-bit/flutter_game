import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final String imageUri;
  final Image image;
  final double borderRadius;
  final VoidCallback onPressed;
  final Color foreColor;
  final Icon icon;
  const CustomButton({
    @required this.color,
    this.text,
    this.borderRadius,
    this.onPressed,
    this.imageUri,
    this.image,
    this.foreColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            image ??
                (imageUri != null ? Image.asset(this.imageUri) : SizedBox()),
            Row(
              children: <Widget>[
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: icon,
                  ),
                if (this.text != null)
                  Text(
                    this.text,
                    style: TextStyle(
                      color: this.foreColor ?? Colors.black,
                      fontSize: 16.5,
                    ),
                  ),
              ],
            ),
            SizedBox(),
          ],
        ),
        onPressed: onPressed,
        color: color ?? MediaQuery.of(context).invertColors,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 0)),
        ));
  }
}
