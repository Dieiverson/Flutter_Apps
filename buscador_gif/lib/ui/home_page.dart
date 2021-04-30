import 'dart:convert';

import 'package:buscador_gif/ui/Gif_Page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart' as KTransparentImage;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

String searchString;

class _HomePageState extends State<HomePage> {
  int _offset = 0;

  Future<Map> SearchGifs() async {
    http.Response response;

    if (searchString == null || searchString.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=DDyrwHm3ZTYXir2v67WvlPj814cQUasg&limit=19&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=DDyrwHm3ZTYXir2v67WvlPj814cQUasg&q=$searchString&limit=19&offset=$_offset&rating=g&lang=pt");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onSubmitted: (texto) {
                setState(() {
                  searchString = texto;
                });
              },
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: SearchGifs(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ));
                default:
                  if (snapshot.hasError)
                    return Container();
                  else
                    return CreateGifTable(context, snapshot);
              }
            },
          ))
        ],
      ),
    );
  }

  Widget CreateGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: GetCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (searchString == null || index < snapshot.data["data"].length) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data["data"][index])));
                },
                onLongPress: () {
                  Share.share(snapshot.data["data"][index]["images"]
                      ["fixed_height"]["url"]);
                },
                child: FadeInImage.memoryNetwork(
                    placeholder: KTransparentImage.kTransparentImage,
                    height: 300.0,
                    fit: BoxFit.cover,
                    image: snapshot.data["data"][index]["images"]
                        ["fixed_height"]["url"]));
          } else {
            return Container(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text(
                      "Carregar Mais...",
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}

int GetCount(List data) {
  if (searchString == null)
    return data.length;
  else
    return data.length + 1;
}
