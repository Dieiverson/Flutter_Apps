import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=d9f91066";
double dolar, euro;
final realController = new TextEditingController();
final dolarController = new TextEditingController();
final euroController = new TextEditingController();
void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
void _clearAll(){
  realController.text = "";
  dolarController.text = "";
  euroController.text = "";
}

void _realChanged(String text){
  if(text.isEmpty) {
    _clearAll();
    return;
  }
  double real = double.parse(text);
  dolarController.text = (real/dolar).toStringAsFixed(2);
  euroController.text = (real/euro).toStringAsFixed(2);
}
void _dolarChanged(String text){
  if(text.isEmpty) {
    _clearAll();
    return;
  }
  double dolarDigitado = double.parse(text);
  realController.text = (dolar * dolarDigitado).toStringAsPrecision(2);
  euroController.text = ((dolar * dolarDigitado)/euro).toStringAsPrecision(2);
}
void _euroChanged(String text){
  if(text.isEmpty) {
    _clearAll();
    return;
  }
  double euroDigitado = double.parse(text);
  realController.text = (euro * euroDigitado).toStringAsPrecision(2);
  dolarController.text = ((euro * euroDigitado)/dolar).toStringAsPrecision(2);
}


class _HomeState extends State<Home> {
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
                          BuildTextField("Reais", "R\$", context, realController,_realChanged),
                          Divider(),
                          BuildTextField("Dólares", "US\$", context, dolarController,_dolarChanged),
                          Divider(),
                          BuildTextField("Euros", "€", context, euroController,_euroChanged),

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
Widget BuildTextField(String label, String prefix, BuildContext context, TextEditingController controller, Function function)
{
  return TextField(
    onChanged: function,
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).hintColor)),
        prefixText: prefix),
    style:
    TextStyle(color: Colors.amber, fontSize: 20.0),
  );
}
