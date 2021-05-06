import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loja_online/models/user_model.dart';
import 'package:loja_online/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrar"),
        centerTitle: true,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor),
              elevation: MaterialStateProperty.all<double>(0.0),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignUpScreen()));
            },
            child: Text(
              "Criar Conta",
              style: TextStyle(fontSize: 15.0),
            ),
          )
        ],
      ),
      body: ScopedModelDescendant<UserModel>(builder: (context,child,model){
        if(model.isLoading)
          return Center(child: CircularProgressIndicator(),);

        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(hintText: "E-mail"),
                keyboardType: TextInputType.emailAddress,
                validator: (text) {
                  if(text.isEmpty || !text.contains("@") )
                    return "E-mail Inválido!";
                  else
                    return null;
                },
              ),
              SizedBox(
                height: 16.0,
              ),
              TextFormField(
                controller: _passController,
                decoration: InputDecoration(hintText: "Senha"),
                obscureText: true,
                validator: (text)
                {
                  if(text.isEmpty || text.length < 6)
                    return "Senha Inválida.";
                  else
                    return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    var snackbar;
                    if(_emailController.text.isEmpty) {
                      snackbar = SnackBar(
                          content: Text(
                              "Insira seu e-mail para recuperação!"),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 3));
                    }
                    else
                      {
                        model.recoverPass(_emailController.text);
                        snackbar = SnackBar(
                            content: Text(
                                "Confira seu e-mail!"),
                            backgroundColor: Theme.of(context).primaryColor,
                            duration: Duration(seconds: 3));
                      }
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);

                  },
                  child: Text(
                    "Esqueci minha senha",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                      shadowColor:
                      MaterialStateProperty.all<Color>(Colors.transparent)),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              SizedBox(
                height: 44.0,
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).primaryColor)),
                    onPressed: () {
                      if(_formKey.currentState.validate())
                        model.signIn(email: _emailController.text,pass: _passController.text,onFail: _onFail, onSuccess: _onSuccess);
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    )),
              )
            ],
          ),
        );
      },
      ),
    );
  }
  void _onFail()
  {
    final snack = SnackBar(
        content: Text("Falha ao Entrar. Verifique o email e senha digitados!"),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 4));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
  void _onSuccess(){
    Navigator.of(context).pop();
  }
}

