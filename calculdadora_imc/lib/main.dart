import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: new Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController weightController = new TextEditingController();
  TextEditingController heightController = new TextEditingController();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _infoText = "Informe seus Dados";

  void resetFields(){
    weightController.text = "";
    heightController.text = "";
    setState(() {
      _infoText = "Informe seus Dados";
      _formKey = GlobalKey<FormState>();
    });

  }

  void calculate(){
    if(weightController.text == "" || heightController.text == "")
      return;

    setState(() {
    double weight = double.parse(weightController.text);
    double height = double.parse(heightController.text) / 100;
    double imc = weight / (height * height);
    if(imc < 18.6){
      _infoText = "Abaixo do Peso (${imc.toStringAsPrecision(3)})";
    } else if(imc >= 18.6 && imc < 24.9){
      _infoText = "Peso Ideal (${imc.toStringAsPrecision(3)})";
    } else if(imc >= 24.9 && imc < 29.9){
      _infoText = "Levemente Acima do Peso (${imc.toStringAsPrecision(3)})";
    } else if(imc >= 29.9 && imc < 34.9){
      _infoText = "Obesidade Grau I (${imc.toStringAsPrecision(3)})";
    } else if(imc >= 34.9 && imc < 39.9){
      _infoText = "Obesidade Grau II (${imc.toStringAsPrecision(3)})";
    } else if(imc >= 40){
      _infoText = "Obesidade Grau III (${imc.toStringAsPrecision(3)})";
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text("Calculadora IMC"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: resetFields)],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Form(
          key:_formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_outline,
                size: 120.0,
                color: Colors.green,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: weightController,
                decoration: new InputDecoration(
                    labelText: "Peso (KG)",
                    labelStyle: new TextStyle(color: Colors.green)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 15.0),
                validator: (value){
                  if(value.isEmpty){
                    return "Insira seu Peso!";
                  }
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: heightController,
                decoration: new InputDecoration(
                    labelText: "Altura (CM)",
                    labelStyle: new TextStyle(color: Colors.green)),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 15.0),
                validator: (value){
                  if(value.isEmpty){
                    return "Insira sua Altura!";
                  }
                },
              ),
              Padding(padding: EdgeInsets.only(top:20.0,bottom: 20.0),
                child: Container(
                    height: 50.0,
                    child: (ElevatedButton(
                      onPressed: (){
                        if(_formKey.currentState.validate()){
                          calculate();
                        }
                      },
                      child: Text(
                        "Calcular",
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ))),),
              Text(
                _infoText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontSize: 15),
              )
            ],
          ),
        )
      )
    );
  }
}
