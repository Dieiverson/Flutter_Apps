import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
      title: "Contador de Pessoas",
      home: Column(
        children: <Widget>[
          Text("Pessoas:0",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ],
      )));
}
