import 'package:flutter/material.dart';

class Roundbutton extends StatelessWidget {
  Roundbutton({this.colur, this.name, this.onpress});
  final Color? colur;
  final String? name;
  final VoidCallback? onpress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colur,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onpress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            name!,
          ),
        ),
      ),
    );
  }
}