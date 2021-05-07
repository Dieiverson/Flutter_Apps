import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tube/blocs/favorit_bloc.dart';
import 'package:flutter_tube/blocs/videos_bloc.dart';
import 'package:flutter_tube/screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(blocs: [
        Bloc((i) => VideosBloc()),
        Bloc((i) => FavoriteBloc())
    ],
    child: MaterialApp(
      title: "FlutterTube",
      home: Home(),
      debugShowCheckedModeBanner: false,
    ),);
  }
}
