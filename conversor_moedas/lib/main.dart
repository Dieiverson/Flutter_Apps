import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=d9f91066";
void main() async {
  runApp(MaterialApp(home: Home(),
  theme: ThemeData(hintColor: Colors.amber,primaryColor: Colors.white),));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando Dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 15),
                      textAlign: TextAlign.center),
                );
              default:
                if (snapshot.hasError)
                  return Center(
                    child: Text("Erro ao carregar dados",
                        style: TextStyle(color: Colors.amber, fontSize: 15),
                        textAlign: TextAlign.center),
                  );
                else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        Icon(Icons.monetization_on,
                            size: 150, color: Colors.amber),
                        TextField(
                          decoration: InputDecoration(labelText: "Reais",
                          labelStyle: TextStyle(color: Colors.amber),
                          border: OutlineInputBorder(borderSide:  BorderSide(color: Colors.pinkAccent ),),
                          prefixText: "R\$"),
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      )
                    ],
                  ));
                }
            }
          }),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}