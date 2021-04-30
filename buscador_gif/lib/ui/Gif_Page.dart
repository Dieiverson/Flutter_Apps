import 'package:flutter/material.dart';
import 'package:share/share.dart';

class GifPage extends StatelessWidget {
 final Map _GifData;
 GifPage(this._GifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_GifData["title"],),
      actions: [IconButton(icon: Icon(Icons.share), onPressed: (){
        Share.share(_GifData["images"]["fixed_height"]["url"]);
      })],
      backgroundColor: Colors.black,),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_GifData["images"]["fixed_height"]["url"]),
      ),
    );
  }
}
