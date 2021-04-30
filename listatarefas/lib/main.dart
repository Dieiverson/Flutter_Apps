import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List toDoList = [];
  final toDoController = TextEditingController();
  Map<String, dynamic> lastRemoved = Map();
  int lastRemovedPos;

  @override
  void addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = toDoController.text;
      toDoController.text = "";
      newToDo["ok"] = false;
      toDoList.add(newToDo);
      _SaveData();
    });
  }

  @override
  void initState() {
    super.initState();
    ReadData().then((data) {
      setState(() {
        toDoList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: toDoController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                ElevatedButton(onPressed: addToDo, child: Text("ADD"))
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                onRefresh: Refresh,
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 10.0),
                    itemCount: toDoList.length,
                    itemBuilder: BuildItem),
              ))
        ],
      ),
    );
  }

  Future<Null> Refresh() async
  {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      toDoList.sort((a,b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });
      _SaveData();
    });

  }

  Widget BuildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          )),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(toDoList[index]["title"]),
        value: toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            toDoList[index]["ok"] = c;
            _SaveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          lastRemoved = Map.from(toDoList[index]);
          lastRemovedPos = index;
          toDoList.removeAt(index);
          _SaveData();
          final snack = SnackBar(
            content: Text("Tarefa ${lastRemoved["title"]} removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  toDoList.insert(lastRemovedPos, lastRemoved);
                  _SaveData();
                });
              },
            ),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> GetFile() async {
    final Directory = await getApplicationDocumentsDirectory();
    return File(Directory.path + "/data.json");
  }

  Future<File> _SaveData() async {
    String data = json.encode(toDoList);
    final File = await GetFile();
    return File.writeAsString(data);
  }

  Future<String> ReadData() async {
    try {
      final File = await GetFile();
      return File.readAsString();
    } catch (e) {
      return null;
    }
  }
}
