import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
      title: "Contador de Pessoas",
      home: Home()
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset("images/restaurant.jpg", fit: BoxFit.cover,height: 1000.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Pessoas:0",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(padding: EdgeInsets.all(10.0), child: FlatButton(
                  onPressed: null,
                  child: Text("+1",
                      style: TextStyle(fontSize: 40.0, color: Colors.white)))),
              Padding(padding: EdgeInsets.all(10.0), child: FlatButton(
                  onPressed: null,
                  child: Text("-1",
                      style: TextStyle(fontSize: 40.0, color: Colors.white)))),
            ]),
            Text("Pode Entrar",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 30.0))
          ],
        )
      ],
    );
  }
}

