import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

bool _isComposing = false;

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);
  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}


class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();

  void reset()
  {
    _controller.text = "";
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
          final picker = ImagePicker();
          picker.getImage(source: ImageSource.camera).then((file) {
            if(file == null)
              return;
            widget.sendMessage(imgFile:File(file.path));


          });
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration.collapsed(hintText: "Digite aqui"),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(text :text);
               reset();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.send), onPressed: _isComposing ? () {
            widget.sendMessage(text:_controller.text);
            reset();

          } : null)
        ],
      ),
    );
  }
}
